#VARIABLES 

DIR_INSTALL := /usr/local/bin
DOWNLOAD_URL := https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
ZIP_FILE := awscliv2.zip

all: help 

help:
	@echo "Comands:"
	@echo "make install           - Baixa e instala o AWS CLI"
	@echo "make check             - Verifica se o AWS CLI esta instalado corretamente"
	@echo "make clean             - Remove arquivos temporário após a instalacao"
	@echo "make terraform_install - Instala o Terraform"
	@echo "make terraform_process - Realiza o processo completo do Terraform"

# Baixar e instalar o AWS CLI
install:
	@echo "Baixando AWC CLI versao."
	@curl -s $(DOWNLOAD_URL) -o "$(ZIP_FILE)"
	@echo "Descompactando o arquivo"
	unzip -q $(ZIP_FILE)
	@echo "Instalando  o AWS CLI"
	sudo ./aws/install --bin-dir $(DIR_INSTALL) --update
	@echo "Instacao concluida"

check: 
	@if command -v aws > /dev/null 2>&1; then \
		echo "AWS CLI instalado com sucesso."; \
		aws --version; \
	else \
		echo "AWS CLI nao instaldo." \
		exit 1; \
	fi

clean:
	@echo "Limpando arquivos temporarios"
	rm -rf $(ZIP_FILE) aws 
	@echo "Arquivos temporarios removidos."

terraform_install: 

	@echo "Inicio da instalacao do  Terraform"
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

	sudo apt-get update

	sudo apt-get install -y terraform
terraform_process:
	@echo "Formata arquivo main.tf"
	terraform fmt
	@echo "Validacao do Terraform."
	terraform validate
	@echo "Plano de execucao do Terraform" 
	terraform plan 

