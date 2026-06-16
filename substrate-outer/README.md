# substrate-outer — 아웃터루프 전용 substrate (인너 미적용)

`substrate/`(인너 `bee substrate up` + 아웃터 ArgoCD 양쪽 적용) 와 달리, 여기 자산은
**아웃터루프(bee-dev/공유환경) 전용**이다. 인너루프는 동등 기능을 다른 메커니즘으로 충족하므로
shared `substrate/` 에 두면 인너 적용이 깨진다(예: ESO CRD 부재).

## ESO (External Secrets Operator) — 아웃터 시크릿 경로 (G27)

모듈 `spec.secrets` 는 dev 에서 chart 가 **ExternalSecret** 으로 렌더(`env!=local` 게이트).
인너루프는 ESO 없이 `bee up` 이 `secrets.local.yaml` 을 직접 Secret 으로 apply(G27) — 그래서
ESO 는 아웃터 전용이고 여기에 둔다.

### 구성 (bee-dev)

1. **ESO operator = 수동 helm 릴리스** (Kong 아웃터와 동류 — ArgoCD화는 후속, G26):
   ```sh
   helm repo add external-secrets https://charts.external-secrets.io
   helm upgrade --install external-secrets external-secrets/external-secrets \
     --kube-context kind-bee-dev -n external-secrets --create-namespace \
     --set installCRDs=true --wait
   ```
2. **ClusterSecretStore = `eso-clustersecretstore.yaml`** (정적, 아래로 apply):
   ```sh
   kubectl --context kind-bee-dev apply -f eso-clustersecretstore.yaml
   ```

### 데모 vs 실환경

- **데모 = fake provider** — store 가 정적 데모 값 반환(AWS 없이). 값=데모 자격증명(substrate 와 동급).
- **실환경 = AWS Secrets Manager** — `values-dev` 의 `asmPrefix` 가 실 ASM 경로, `secretStore` 가
  IRSA SecretStore. ExternalSecret 계약(remoteRef key/property)은 **동일** — provider 만 교체(G28 방향).

### remoteRef 계약

`remoteRef.key = <asmPrefix>/<env>/<module>/<group>`, `property = BITCERT_*`.
fake.data[].value = 그 group 의 properties JSON(ESO 가 gjson 으로 property 추출). 모듈 values-dev 의
`asmPrefix`(=bitcert) · `secretStore`(=ClusterSecretStore/bee-demo-store) 좌표와 짝.

> 연기: ESO operator·store 의 ArgoCD화(bee-substrate-dev App 또는 helm App) — 아웃터 Kong 과 함께 Stage 4 prep.
