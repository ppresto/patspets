terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "Patrick"

        workspaces {
            name = "WORKSPACE_NAME_PLACEHOLDER"
        }
    }
}