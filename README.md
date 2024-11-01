<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Contexto do Projeto" alt="Typing SVG" /></a>
### Contexto Inicial
**App de Registro de Ponto com Geolocalização e Biometria:**
Um aplicativo que permite ao funcionário registrar seu ponto de trabalho quando estiver a até 100 metros do local de trabalho. A autenticação pode ser feita via NIF e senha ou utilizando reconhecimento digital e/ou facial via biometria.

<br>
<br>
<br>
<p align="center">
   <img src="/src/logo/logo.png" alt="logo" width=250px>
</p>

<p align="center">
   <img src="https://img.shields.io/badge/Backend-FEITO-blue?style=for-the-badge" alt="backend" />
  <img src="https://img.shields.io/badge/Documentação-FEITO-blue?style=for-the-badge" alt="documentação" />
  <img src="https://img.shields.io/badge/Manual-FEITO-blue?style=for-the-badge" alt="mobile" />
  <img src="https://img.shields.io/badge/Frontend-FEITO-blue?style=for-the-badge" alt="site" />
</p>
<hr>
<br>
<br><br><br>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Registro de Ponto" alt="Typing SVG" /></a>

## Apresentação do Projeto: Desenvolvimento de Aplicativo sobre Registro de Ponto

### Visão Geral do Projeto
**Objetivo:**
Desenvolver um aplicativo para registro de ponto do funcionário, efetuando o seu login pelo meio padrão com o seu email e a sua senha ou utilizando a sua digital e/ou reconhecimento facial via biometria. Além disso, para ele efetuar o seu registro ele precisará estar até 100 metros do local do seu trabalho, caso contrário o registro não será possível e ele receberá uma notificação no aplicativo.

**Por Que Este Projeto?**
A nossa empresa chamada FastPoint, dedicada a inovar no campo da gestão de serviços, está em processo de criação de um aplicativo de registro de ponto do funcionário com geolocalização e biometria. Este projeto visa proporcionar uma experiência eficiente e ágil para o funcionário, facilitando o processo de registro e autenticação por meio da sua biometria. Com o objetivo de transformar a forma como a nossa empresa registra o ponto do funcionário, estamos desenvolvendo uma solução tecnológica avançada que ofereça uma interface amigável e funcionalidades robustas.
<br><br><br><br><br>
<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Escopo" alt="Typing SVG" /></a>

O registro de ponto será desenvolvido utilizando o framework Flutter, com Firebase para nossa plataforma de serviços de backend. A solução visa proporcionar uma experiência para o funcionário eficiente e intuitiva, com recursos para autenticação via biometria digital e/ou facial, além da sua geolocalização em tempo real para o registro do ponto.
<br><br><br><br><br>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Ferramentas Utilizadas" alt="Typing SVG"/></a>

**Firebase:**
- Authentication
- Cloud Firestore

**Framework Flutter (dependências):**
- **cloud_firestore** (relacionada ao firebase)
- **firebase_auth** (relacionado ao firebase)
- **firebase_core** (relacionado ao firebase)
- **firebase_messaging** (relacionado ao firebase)
- **local_auth** (autenticação via biometria)
- **flutter_secure_storage** (autenticação via biometria)
- **geolocator** (localização)
- **flutter_map** (mapa visual)

**Outros:**
- Android Studio para desenvolvimento
- Github para versionamento
- Figma para montagem dos protótipos

<br><br><br><br><br>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Diagrama de Classe" alt="Typing SVG" />

```mermaid
classDiagram
    class Usuario {
        - String nome
        - String email
        - String senha
        - String imagem_url
    }

    class MarcacaoPontos {
        - Date data
        - double latitude
        - double longitude
        - long timestamp
        - String tipo
    }

```

<br><br><br><br><br>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Diagrama de Fluxo" alt="Typing SVG" />

```mermaid
flowchart TD
    A[Início] --> B[Abrir App]
    B --> C{Primeiro Login}
    
    C -->|NIF e Senha| D[Inserir NIF e Senha]
    C -->|Biometria Facial ou Digital| E[Configurar Biometria]
    
    D --> G[Acessar Sistema]
    E --> G[Acessar Sistema]

    G --> H{Próximo Registro de Ponto?}
    
    H -->|Sim| I{Condição: Raio de 100 metros}
    
    I -->|Dentro do Raio| J[Registrar Ponto]
    J --> K[Confirmação de Registro]
    
    I -->|Fora do Raio| L[Exibir Notificação]
    
    H -->|Não| M[Encerrar App]


```

<br><br><br><br><br>

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Manual do Usuário" alt="Typing SVG" />

### - Requisitos:

- Conexão com a Internet
- Dispositivo com funcionalidade biométrica e facial

### 1. Acesso ao Aplicativo

1.1 **Entrada:**
   - Entre no aplicativo pelo seu dispositivo.

1.2. **Primeiro Login:**
   - Ao acessar pela primeira vez, insira seu **NIF e senha** ou configure sua biometria facial/digital para um login mais rápido e seguro.
<br><br>
### 2. Autenticação

#### O FastPoint oferece duas opções de autenticação:

2.1 **NIF e senha:**
   - Insira suas credenciais para acessar o sistema.

2.2 **Reconhecimento facial ou digital:**
   - Utilize biometria para maior agilidade e segurança.
<br><br>
### 3. Registro de Ponto

#### Condições para registro:
   - O registro é permitido apenas se você estiver dentro de um raio de 100 metros do local de trabalho.
   - A geolocalização é verificada automaticamente no momento do registro.

#### Passo a passo:
   - Abra o aplicativo e escolha a forma de autenticação (biometria ou NIF e senha).
   - Aproxime-se do local de trabalho até que a localização seja validada.
   - Clique no botão **"Registrar Ponto"**.
   - Verifique a confirmação do registro na tela.

<br><br>
### 4. Notificações e Falhas no Registro

#### Caso esteja fora do limite de 100 metros, o aplicativo exibirá uma notificação:
**"Não foi possível registrar o ponto. Você está fora do limite permitido."**


<br><br><br><br><br>
<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=440&size=22&pause=1000&color=9c20f5&center=false&vCenter=false&repeat=false&width=435&lines=Desenvolvedores do Projeto" alt="Typing SVG" />

<div align=center>
  <table style="width: 100%">
    <tbody>
      <tr align=center>
        <th><strong> Eduardo Sinico </br> Edu1Sinico </strong></th>
        <th><strong> João Victor de Lima </br> JoaovlLima </strong></th>
        <th><strong> Rafael Souza de Moura </br> rafaelmoura23</strong></th>
         <th><strong> Vinícius Granço Feitoza </br> epicestudar </strong></th>
      </tr>
      <tr align=center>
        <td>
          <a href="https://github.com/Edu1Sinico">
            <img width="250" height="200" style="border-radius: 50%;" src="https://avatars.githubusercontent.com/Edu1Sinico">
          </a>
        </td>
        <td>
          <a href="https://github.com/JoaovlLima">
            <img width="250" height="200" style="border-radius: 50%;" src="https://avatars.githubusercontent.com/JoaovlLima">
          </a>
        </td>
         <td>
          <a href="https://github.com/rafaelmoura23">
            <img width="250" height="200" style="border-radius: 50%;" src="https://avatars.githubusercontent.com/rafaelmoura23">
          </a>
        </td>
         <td>
          <a href="https://github.com/epicestudar">
            <img width="250" height="200" style="border-radius: 50%;" src="https://avatars.githubusercontent.com/epicestudar">
          </a>
        </td>
      </tr>
    </tbody>

  </table>
</div>
