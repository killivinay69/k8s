pipeline {
  agent {
     kubernetes {
      defaultContainer 'glams-jenkins-slave'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: glams-amazon-jdk
spec:
  tolerations:
  - effect: NoSchedule
    key: cattle.io/os
    operator: Equal
    value: linux
  volumes:
    - name: docker-sock
      hostPath:
        path: /var/run/docker.sock
  containers:
  - name: glams-jenkins-slave
    image: registry.glams.com/glams/jenkins-agent:latest
    imagePullPolicy: Always
    command:
    - cat
    tty: true
    resources:
      requests:
        memory: "2Gi"
    volumeMounts:
     - name: docker-sock
       mountPath: /var/run/docker.sock
"""
    }
}

triggers {
  pollSCM('H/2 * * * *')
}

options {
  buildDiscarder(logRotator(numToKeepStr: '10'))
  skipStagesAfterUnstable()
  durabilityHint('PERFORMANCE_OPTIMIZED')
  disableConcurrentBuilds()
  skipDefaultCheckout(true)
  overrideIndexTriggers(false)
}

stages {
  stage ('Checkout'){
    steps {
      checkout scm
      script {
        env.commit_id = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
      }
      withCredentials([file(credentialsId: 'DEV_K8S_HQ', variable: 'DEV_K8S_HQ')]) {
        sh 'cat $DEV_K8S_HQ > /opt/dev_k8s_hq_kubeconfig.yaml'
        sh 'chmod 0600 /opt/dev_k8s_hq_kubeconfig.yaml'
      }
    }
  }

  stage('Docker Build') {
    steps {
      script {
        docker.build('glams/api-builder', '--network host --pull .')
        docker.withRegistry('https://registry.glams.com') {
          docker.image('glams/api-builder').push(commit_id)
       }
      }
    }
  }

  stage ('DEV Deployment') {
    when {
      beforeAgent true
      branch "feature/docker"
    }
    steps {
        sh '''
        helm3 upgrade --install api-builder \
        --namespace dev --create-namespace \
        --set-string image.tag=${commit_id} \
        --timeout 600s \
        --wait \
        ./charts/api-builder  \
        --kubeconfig /opt/dev_k8s_hq_kubeconfig.yaml || exit 1
        '''
    }
  }

}
}
