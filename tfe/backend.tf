terraform {
    backend "remote" {
        hostname = "app.terraform.io"
        organization = "Patrick"

        workspaces {
            name = "patspets_master"
        }
    }
}