locals {
  task = templatefile("${path.module}/src/config/task.template.sh",
    {
      deploy_workflow_token = var.deploy_workflow_token
    }
  )
}
