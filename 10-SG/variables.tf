variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev" 
}

variable "common_tags" {
    default = {
        Project = "expense"
        Terraform = "true"
        Environment = "dev"
    }
}

variable "mysql_sg_tags" {
    default = {
        Component = "mysql"
    }
} 



variable "bastion_sg_tags" {
    default = {
        Component = "bastion"
    }
}



# variable "app_alb_sg_tags" {
#     default = {
#         Component = "app-alb" 
#     }
# }

# variable "web_alb_sg_tags" {
#     default = {
#         Component = "web-alb"  
#     }
# }

variable "node_sg_tags" {
    default = {
        Component = "node"  
    }
}

variable "eks_control_plane_sg_tags" {
    default = {
        Component = "eks-control-plane"   
    }
}

variable "ingress_alb_sg_tags" {
    default = {
        Component = "ingress-alb"   
    }
}