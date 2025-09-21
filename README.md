# Quartinho App

Uma aplicação React moderna para encontrar quartos e colegas de quarto.

## 🏠 Sobre o Projeto

O Quartinho é uma plataforma que conecta pessoas que procuram quartos com aquelas que têm quartos disponíveis. A aplicação oferece uma experiência intuitiva para:

- **Procurar quartos**: Encontre o espaço perfeito para você
- **Encontrar colegas de quarto**: Divida custos e faça novas amizades

## ✨ Funcionalidades

- 🎨 Design moderno e responsivo
- 📱 Interface mobile-first
- 🔐 Sistema de cadastro e login
- 🏡 Categorização de usuários (procurando quarto vs. procurando colega)
- 🎯 Fluxo de onboarding personalizado

## 🛠️ Tecnologias Utilizadas

- **React 18** - Biblioteca para interfaces de usuário
- **TypeScript** - Tipagem estática para JavaScript
- **Vite** - Build tool rápida e moderna
- **Tailwind CSS** - Framework CSS utilitário
- **React Router DOM** - Roteamento para React
- **Lucide React** - Ícones modernos
- **Radix UI** - Componentes acessíveis

## 🚀 Como Executar

1. **Clone o repositório**
   ```bash
   git clone https://github.com/seu-usuario/quartinho-app.git
   cd quartinho-app
   ```

2. **Instale as dependências**
   ```bash
   npm install
   ```

3. **Execute o projeto**
   ```bash
   npm run dev
   ```

4. **Acesse no navegador**
   ```
   http://localhost:5173
   ```

## 📁 Estrutura do Projeto

```
src/
├── components/ui/          # Componentes reutilizáveis
├── screens/               # Páginas da aplicação
│   ├── Element/          # Página inicial
│   ├── EmailLogin/       # Página de login
│   ├── Register/         # Página de cadastro
│   └── UserPreference/   # Página de preferências
├── lib/                  # Utilitários
└── App.tsx              # Componente principal
```

## 🎨 Design System

- **Cor primária**: Laranja (#F97316)
- **Tipografia**: Sistema padrão com fallbacks
- **Bordas**: Arredondadas (rounded-lg, rounded-full)
- **Espaçamento**: Baseado no sistema Tailwind

## 🚧 Próximos Passos

- [ ] Implementar backend para persistência de dados
- [ ] Adicionar sistema de busca e filtros
- [ ] Implementar chat entre usuários
- [ ] Adicionar sistema de avaliações
- [ ] Integrar com mapas para localização

## 🤝 Contribuição

Contribuições são bem-vindas! Por favor, abra uma issue ou pull request.

## 📄 Licença

Este projeto está sob a licença MIT.