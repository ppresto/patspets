terraform {
    backend "remote" {
        hostname = "myjenkins.hashidemo.io"
        organization = "Patrick"

        workspaces {
            name = "patspets"
        }
    }
}