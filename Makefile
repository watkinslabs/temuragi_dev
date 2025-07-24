# Master Makefile for Temuragi Project

.PHONY: all build push build-push clean help clone setup

REPOS := init backend web
K8S_DIR := k8s

help:
	@echo "Temuragi Master Build System"
	@echo "Usage: make [target]"
	@echo ""
	@echo "Setup targets:"
	@echo "  clone        Clone all repositories"
	@echo "  setup        Setup all repositories"
	@echo ""
	@echo "Build targets:"
	@echo "  build        Build all Docker images"
	@echo "  push         Push all images to registry"
	@echo "  build-push   Build and push all images"
	@echo ""
	@echo "Individual builds:"
	@echo "  build-init     Build init container"
	@echo "  build-backend  Build backend"
	@echo "  build-web      Build web UI"
	@echo ""
	@echo "K8s targets:"
	@echo "  deploy       Deploy to Kubernetes"
	@echo "  undeploy     Remove from Kubernetes"
	@echo ""
	@echo "Maintenance:"
	@echo "  clean        Clean all images"

clone:
	@if [ ! -d "init" ]; then \
		git clone git@github.com:watkinslabs/temuragi_init.git init; \
	fi
	@if [ ! -d "backend" ]; then \
		git clone git@github.com:watkinslabs/temuragi_backend.git backend; \
	fi
	@if [ ! -d "web" ]; then \
		git clone git@github.com:watkinslabs/temuragi_web.git web; \
	fi
	@if [ ! -d "k8s" ]; then \
		git clone git@github.com:watkinslabs/temuragi_manifest.git k8s; \
	fi

setup: clone
	@echo "Setting up all repositories..."
	@for repo in $(REPOS); do \
		echo "Setting up $$repo..."; \
		cd $$repo && git pull && cd ..; \
	done
	@cd $(K8S_DIR) && git pull && cd ..

build-init:
	@echo "Building init container..."
	@cd init && $(MAKE) build

build-backend:
	@echo "Building backend..."
	@cd backend && $(MAKE) build

build-web:
	@echo "Building web UI..."
	@cd web && $(MAKE) build

build: build-init build-backend build-web

push-init:
	@cd init && $(MAKE) push

push-backend:
	@cd backend && $(MAKE) push

push-web:
	@cd web && $(MAKE) push

push: push-init push-backend push-web

build-push-init:
	@cd init && $(MAKE) build-push

build-push-backend:
	@cd backend && $(MAKE) build-push

build-push-web:
	@cd web && $(MAKE) build-push

build-push: build-push-init build-push-backend build-push-web

clean:
	@for repo in $(REPOS); do \
		echo "Cleaning $$repo..."; \
		cd $$repo && $(MAKE) clean && cd ..; \
	done

deploy:
	@echo "Deploying to Kubernetes..."
	@cd $(K8S_DIR) && kubectl apply -k .

undeploy:
	@echo "Removing from Kubernetes..."
	@cd $(K8S_DIR) && kubectl delete -k .

status:
	@echo "=== Git Status ==="
	@for repo in $(REPOS) $(K8S_DIR); do \
		echo "\n--- $$repo ---"; \
		cd $$repo && git status -s && cd ..; \
	done

update-all:
	@echo "Updating all repositories..."
	@for repo in $(REPOS) $(K8S_DIR); do \
		echo "\n--- Updating $$repo ---"; \
		cd $$repo && git pull && cd ..; \
	done

versions:
	@echo "=== Component Versions ==="
	@echo -n "Init:    "; cat init/VERSION 2>/dev/null || echo "VERSION file not found"
	@echo -n "Backend: "; cat backend/VERSION 2>/dev/null || echo "VERSION file not found"
	@echo -n "Web:     "; cat web/VERSION 2>/dev/null || echo "VERSION file not found"