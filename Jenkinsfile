pipeline {
    agent any
    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
        timeout(time: 45, unit: 'MINUTES')
    }
    parameters {
        string(name: 'SOURCE_URL', defaultValue: 'https://github.com/FacundoCoria/EntregableDevops2.git', description: 'Repositorio Git publicado del Laboratorio 4.')
        string(name: 'SOURCE_REF', defaultValue: 'lab4/b05-consolidacion-entrega', description: 'Rama o commit a construir; debe existir en SOURCE_URL.')
        string(name: 'IMAGE_REPOSITORY', defaultValue: 'brunovitola/pedidos-api-l4', description: 'Docker Hub: usuario/pedidos-api-l4')
    }
    environment {
        PATH = "/var/jenkins_home/l4-tools/bin:${env.PATH}"
        SEMGREP_SEND_METRICS = 'off'
        SEMGREP_ENABLE_VERSION_CHECK = '0'
        APP = 'pedidos-api/pedidos-api'
    }
    stages {
        stage('1. Clonacion') {
            steps {
                script {
                    env.EVIDENCE = "${env.WORKSPACE}/evidencia-${env.BUILD_NUMBER}"
                    env.SOURCE_URL = params.SOURCE_URL ?: 'https://github.com/FacundoCoria/EntregableDevops2.git'
                    env.SOURCE_REF = params.SOURCE_REF ?: 'lab4/b05-consolidacion-entrega'
                    env.IMAGE_REPOSITORY = params.IMAGE_REPOSITORY ?: 'brunovitola/pedidos-api-l4'
                }
                sh 'mkdir -p "$EVIDENCE"'
                dir('fuente-l4') {
                    deleteDir()
                    sh '''
                        set -eu
                        git clone --no-local -- "$SOURCE_URL" .
                        if ref=$(git rev-parse --verify --end-of-options "refs/remotes/origin/$SOURCE_REF^{commit}" 2>/dev/null); then
                            :
                        else
                            ref=$(git rev-parse --verify --end-of-options "$SOURCE_REF^{commit}")
                        fi
                        git checkout --detach "$ref"
                        git rev-parse HEAD > "$EVIDENCE/commit.txt"
                        git status --porcelain > "$EVIDENCE/source-status.txt"
                        sha256sum "$APP/pom.xml" "$APP/Dockerfile" > "$EVIDENCE/source-sha256.txt"
                        sh ci/bootstrap-tools.sh > "$EVIDENCE/herramientas.log" 2>&1
                        cat "$EVIDENCE/herramientas.log"
                    '''
                }
            }
        }
        stage('2. Semgrep') {
            steps {
                dir('fuente-l4') {
                    sh '''
                        set -eu
                        cd "$APP"
                        semgrep scan --config security/semgrep --metrics=off --disable-version-check \
                          --strict --error --no-rewrite-rule-ids \
                          --json-output "$EVIDENCE/semgrep.json" \
                          --text --output "$EVIDENCE/semgrep.txt" src \
                          > "$EVIDENCE/semgrep.log" 2>&1
                        cat "$EVIDENCE/semgrep.log"
                    '''
                }
            }
        }
        stage('3. Snyk y bloqueo de criticos') {
            steps {
                withCredentials([string(credentialsId: 'l4-snyk-token', variable: 'SNYK_TOKEN')]) {
                    dir('fuente-l4') {
                        script {
                            def result = sh(returnStatus: true, script: '''
                                set +x
                                cd "$APP" || exit 2
                                chmod +x mvnw || exit 2
                                snyk test --file=pom.xml --dev --ignore-policy \
                                  --json-file-output="$EVIDENCE/snyk.json" \
                                  > "$EVIDENCE/snyk-output.txt" 2>&1
                            ''')
                            writeFile file: "${env.EVIDENCE}/snyk-exit.txt", text: "${result}\n"
                            sh 'python3 ci/gate-snyk.py "$EVIDENCE/snyk.json" "$(cat "$EVIDENCE/snyk-exit.txt")"'
                        }
                    }
                }
            }
        }
        stage('4. Compilacion y pruebas') {
            steps {
                dir('fuente-l4') {
                    sh '''
                        set -eu
                        cd "$APP"
                        ./mvnw -B -ntp -Dspring.datasource.url=jdbc:h2:mem:cijenkins clean verify \
                          > "$EVIDENCE/maven.log" 2>&1
                        cat "$EVIDENCE/maven.log"
                        ./mvnw -B -ntp dependency:tree > "$EVIDENCE/dependency-tree.txt" 2>&1
                    '''
                }
            }
        }
        stage('5. Imagen y publicacion Docker') {
            steps {
                script {
                    if (!(env.IMAGE_REPOSITORY ==~ /[a-z0-9][a-z0-9_-]*\/pedidos-api-l4/)) {
                        error('Indicar IMAGE_REPOSITORY: usuario/pedidos-api-l4')
                    }
                    env.IMAGE_TAG = "${env.IMAGE_REPOSITORY}:l4-${env.BUILD_NUMBER}-${readFile("${env.EVIDENCE}/commit.txt").trim().take(12)}"
                }
                dir('fuente-l4') {
                    sh '''#!/bin/bash
                        set -euo pipefail
                        docker build --iidfile "$EVIDENCE/image-id.txt" -t "$IMAGE_TAG" "$APP" \
                          2>&1 | tee "$EVIDENCE/docker-build.log"
                        test "$(docker image inspect --format '{{.Config.User}}' "$IMAGE_TAG")" = '10001:10001'
                    '''
                }
                withCredentials([usernamePassword(credentialsId: 'l4-dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_TOKEN')]) {
                    sh '''#!/bin/bash
                        set +x
                        set -euo pipefail
                        test "${IMAGE_TAG%%/*}" = "$DOCKER_USER"
                        DOCKER_CONFIG=$(mktemp -d)
                        export DOCKER_CONFIG
                        trap 'rm -f "$DOCKER_CONFIG/config.json"; rmdir "$DOCKER_CONFIG"' EXIT
                        printf '%s' "$DOCKER_TOKEN" | docker login --username "$DOCKER_USER" --password-stdin \
                          > "$EVIDENCE/docker-login.txt" 2>&1
                        docker push "$IMAGE_TAG" 2>&1 | tee "$EVIDENCE/docker-push.log"
                        docker image inspect --format '{{json .RepoDigests}}' "$IMAGE_TAG" > "$EVIDENCE/image-digests.json"
                        printf '%s\n' "$IMAGE_TAG" > "$EVIDENCE/image-tag.txt"
                    '''
                }
            }
        }
        stage('6. Despliegue Helm') {
            steps {
                dir('fuente-l4') {
                    sh '''
                        set -eu
                        export KUBECONFIG=/var/jenkins_home/l4-kube/config
                        sh ci/deploy.sh > "$EVIDENCE/helm.log" 2>&1
                        cat "$EVIDENCE/helm.log"
                    '''
                }
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: "evidencia-${env.BUILD_NUMBER}/**", allowEmptyArchive: true
            junit testResults: 'fuente-l4/pedidos-api/pedidos-api/target/surefire-reports/TEST-*.xml', allowEmptyResults: true
        }
    }
}
