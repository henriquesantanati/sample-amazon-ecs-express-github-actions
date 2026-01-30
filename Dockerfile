# checkov:skip=CKV_DOCKER_3:Base image Dockerfile created a user - https://github.com/aws-containers/retail-store-sample-app/blob/main/src/ui/Dockerfile Using root user is acceptable for this application context
# checkov:skip=CKV_DOCKER_2:HEALTHCHECK not required - ECS/ALB handles health checks
# nosemgrep: dockerfile-source-not-pinned

FROM public.ecr.aws/aws-containers/retail-store-sample-ui:1.3.0

EXPOSE 8080