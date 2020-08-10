pipeline{

  agent { label 'slave-1'}

  stages {

    stage('Build app with docker'){
      when {
        expression {
          env.BRANCH_NAME in ["master"]
        }
      }
      steps{
        script {
          docker.withTool('Docker') {
            docker.withRegistry('http://localhost:5000') {
              def customImage = docker.build("cggg88jorge/elixir-app",'.')
              customImage.push()
            }
          }
        }
      }
    }

    stage('Deploy app in host docker'){
      when {
        expression {
          env.BRANCH_NAME in ["master"]
        }
      }
      steps{
        sh "echo 'docker run -p 4000:4000 -d --name elixirapp elixirapp' | ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -t cggg88jorge@192.168.100.2"
      }
    }
  }

  post{
    always {
      cleanWs()
    }
  }

}

