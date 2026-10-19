# DevOps CI/CD Capstone — Hello DevOps

Демонстрационный проект: Spring Boot HTTP-приложение, Maven-тесты, Docker-образ в Yandex Container Registry (YCR), деплой в Kubernetes через Helm, Terraform для инфраструктуры, Prometheus/Grafana/Loki для мониторинга и логирования.


## Состав репозитория

- `app/` — Spring Boot приложение и unit-тест.
- `Dockerfile`, `.dockerignore` — воспроизводимая сборка контейнера.
- `Jenkinsfile` — CI: тесты, сборка, публикация версионированного образа; CD: Helm-деплой и smoke test.
- `k8s/` — базовые Kubernetes-манифесты.
- `helm/hello-app/` — Helm chart приложения.
- `terraform/` — Yandex Cloud: сеть, Container Registry, Managed Kubernetes и node group.
- `terraform/backend.hcl.example` — пример параметров S3 backend для Yandex Object Storage.
- `monitoring/` — values для kube-prometheus-stack и Loki/Grafana.
- `scripts/` — вспомогательные команды.

## Архитектура

GitHub → Jenkins → Maven test/package → Docker build → YCR → Helm upgrade → Yandex Managed Kubernetes → Internet via LoadBalancer/Ingress.

Prometheus собирает метрики Kubernetes; Grafana предоставляет дашборды; Loki и Promtail собирают логи контейнеров.

## 1. Приложение и локальная проверка

Требования: Java 17+, Maven 3.9+, Docker (для контейнерной сборки), kubectl/Helm для деплоя.

```bash
cd app
mvn clean verify
cd ..
docker build -t hello-app:local .
docker run --rm -p 8080:8080 hello-app:local
curl http://localhost:8080/
curl http://localhost:8080/actuator/health
```

Endpoints:
- `/` — приветствие.
- `/actuator/health` — health check.
- `/actuator/prometheus` — метрики для Prometheus.

## 2. Git flow и релиз

Рекомендуемый поток:
1. Создавать feature-ветку от `develop`.
2. Открывать PR в `develop`; Jenkins проверяет тесты и сборку.
3. PR из `develop` в `main` — релизная проверка.
4. Для релиза создать тег `vX.Y.Z` (например, `v1.0.0`).
5. Jenkins публикует образ с тегом commit SHA и номером сборки. Для релизного тега дополнительно используется тег версии.
6. После успешной сборки Jenkins выполняет `helm upgrade --install` в целевой кластер.

`latest` не используется как единственный идентификатор. В production рекомендуется деплоить неизменяемый SHA/tag и хранить release notes.

## 3. Подготовка Yandex Cloud

Создайте заранее:
- Yandex Cloud folder и billing.
- service account для Terraform с правами, необходимыми для создания VPC, Container Registry и Managed Kubernetes; используйте минимально необходимые роли.
- Object Storage bucket для Terraform state.
- S3 access key/secret key для backend.
- YCR service account/key для push image.
- DNS-запись для публичного адреса приложения, если нужен собственный домен.

### Terraform remote state

Terraform backend S3 должен быть подготовлен до `terraform init`. Bucket создаётся заранее (backend не может создать bucket, в котором сам хранит state).

```bash
cd terraform
cp backend.hcl.example backend.hcl
# Отредактируйте backend.hcl локально. Не коммитьте файл с ключами.
terraform init -backend-config=backend.hcl
terraform plan -out=tfplan
terraform apply tfplan
```

Перед запуском задайте `YC_TOKEN` или настройте авторизацию YC CLI и экспортируйте `YC_CLOUD_ID`, `YC_FOLDER_ID`. Заполните `terraform.tfvars` из `terraform.tfvars.example`. Не храните реальные credentials в Git.

Terraform output покажет registry id и cluster id. Kubeconfig можно получить через YC CLI, используя имя/ID кластера из outputs.


## 4. Jenkins credentials и параметры

Настройте Jenkins agent с Java 17, Maven, Docker CLI, `kubectl`, Helm и доступом к Docker daemon. На agent должен быть доступен `yc` CLI, если используется получение kubeconfig через CLI; альтернативно храните kubeconfig как Secret file credential.

Создайте credentials:
- `ycr-sa-key` — **Secret file** с JSON-ключом сервисного аккаунта для YCR.
- `kubeconfig-capstone` — **Secret file** с kubeconfig для целевого кластера.

Задайте параметры job:
- `YCR_REGISTRY_ID` — ID Yandex Container Registry.
- `YCR_IMAGE_NAME` — имя образа, например `hello-app`.
- `K8S_NAMESPACE` — namespace, по умолчанию `hello-app`.
- `HELM_RELEASE` — Helm release, по умолчанию `hello-app`.

Jenkinsfile публикует образы в `cr.yandex/<registry-id>/<image-name>:<git-sha>` и `:<build-number>`. На тегах `v*` добавляет тег версии. Pipeline запускает деплой на ветках `main` и `develop`, а feature-ветки только тестируют и собирают.

## 5. Ручной деплой (если требуется)

```bash
kubectl create namespace hello-app
helm upgrade --install hello-app ./helm/hello-app \
  --namespace hello-app \
  --set image.repository=cr.yandex/<REGISTRY_ID>/hello-app \
  --set image.tag=<GIT_SHA>
```

Публичный Service типа `LoadBalancer` выдаст внешний IP в облаке. Проверить:
```bash
kubectl -n hello-app get svc
kubectl -n hello-app get pods
```

`k8s/` содержит эквивалентные базовые манифесты; Helm chart является предпочтительным способом деплоя в pipeline.

## 6. Мониторинг и логирование

`monitoring/kube-prometheus-stack-values.yaml` включает Prometheus, Grafana и Alertmanager. `monitoring/loki-values.yaml` — Loki single-binary для учебной конфигурации. Эти конфигурации предназначены для небольшого учебного кластера, не для production.

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack-values.yaml

helm upgrade --install loki grafana/loki \
  -n monitoring -f monitoring/loki-values.yaml
helm upgrade --install promtail grafana/promtail \
  -n monitoring
```

Получить пароль Grafana:
```bash
kubectl -n monitoring get secret monitoring-grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d; echo
```

Для доступа в учебной среде используйте port-forward, а не открывайте Grafana наружу без аутентификации:
```bash
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
```
Откройте `http://localhost:3000`. Promtail отправляет container logs в Loki; Prometheus/Grafana показывают состояние кластера и приложения.

## 7. Правила изменения инфраструктуры

1. Все изменения Terraform — через отдельную feature-ветку и PR.
2. Запускать `terraform fmt -recursive`, `terraform validate` и просматривать `terraform plan`.
3. Не запускать `terraform apply` из PR без ручного approval.
4. Не коммитить `terraform.tfstate`, `tfplan`, `backend.hcl`, `terraform.tfvars`, kubeconfig, service-account keys.
5. Изменения Helm values и Kubernetes ресурсов проверять на тестовом окружении до production.
6. Для отката приложения: `helm rollback hello-app <REVISION> -n hello-app`.

## 8. Безопасность и ограничения

- Реальные секреты передавать через Jenkins Credentials/secret manager.
- Kubernetes Secret по умолчанию лишь base64-кодирует значения; включите encryption at rest и ограничьте RBAC в целевом кластере.
- Не открывайте Grafana и Kubernetes API всему Интернету.
- Terraform state может содержать чувствительные данные: используйте приватный bucket, шифрование и ограниченные IAM-права.
- Перед production примените resource limits, Pod Security, NetworkPolicy, TLS, backups, alert rules и проверку уязвимостей образов.
