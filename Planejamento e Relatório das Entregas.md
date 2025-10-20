**Introdução do projeto**
O Quartinho é uma plataforma online dedicada a conectar alunos recém-chegados na cidade e que procuram um lugar para morar, a outros estudantes que buscam um colega de quarto. Usando filtros customizáveis e eliminando intermediários, a iniciativa procura facilitar o processo de encontrar um novo lar numa cidade nova, garantindo segurança e praticidade, para que os estudantes possam focar no que realmente interessa: sua vida acadêmica e novas experiências.

**Considerações adicionais**
Algumas mudanças foram feitas ao planejamento original do projeto, levando em consideração o feedback recebido pela equipe do Desafio Liga Jovem, e pretendemos continuar melhorando o Quartinho de acordo com os resultados do Desafio.


**Requisitos Funcionais**

| Requisito | Descrição |
|---|---|
| RF 01 | Cadastro de usuários (locatários e inquilinos) |
| RF 02 | Cadastro, edição e exclusão de imóveis (CRUD) |
| RF 03 | Pesquisa de imóveis com filtros avançados |
| RF 04 | Exibição de fotos dos imóveis |
| RF 05 | Chat seguro entre inquilino e locatário |
| RF 06 | Exibição de perfil de locatários e inquilinos |
| RF 07 | Notificações automáticas para atualizações e interações no app |
| RF 08 | Perfil detalhado dos imóveis e usuários cadastrados |
| RF 09 | Suporte ao cliente |
| RF 10 | Parcerias com prestadores de serviços |
| RF 11 | Verificação de perfil do inquilino e do locatário |
| RF 12 | Contratos dos aluguéis |
| RF 13 | Notificações sobre pagamentos dos aluguéis para os inquilinos |
| RF 14 | Favoritos |
| RF 15 | Mostrar imóveis com base na proximidade de Universidades |

**PLANEJAMENTO SEMANAL**

**SEMANA 01 - INÍCIO DAS ATIVIDADES**
Documentação, prototipação e planejamento básicos do projeto; Requisito funcional 01 do projeto (cadastro de usuários).

**SPRINT 01**
Consolidar a base funcional do aplicativo
Melhoria do projeto lógico do projeto (Vinícius);
Requisitos 02 ~ 04 - CRUD com os imóveis.


**SPRINT 02**
**
**RF02 - USER STORY**
Como estudante/proprietário, quero cadastrar um imóvel (endereço, preço, fotos, regras da casa, vagas disponíveis), para oferecer a outros estudantes.

Como estudante, quero visualizar imóveis cadastrados em detalhes, para avaliar se atendem minhas necessidades.

Como proprietário, quero editar informações do meu imóvel (preço, fotos, disponibilidade), para manter o anúncio atualizado.

Como proprietário, quero excluir um imóvel, quando não estiver mais disponível.


**Tarefas técnicas**
Modelar entidade de Imóvel no banco de dados (campos: endereço, preço, descrição, fotos, número de vagas, restrições, dono_id);

Implementar endpoints de API REST/GraphQL para criar, listar, atualizar e excluir imóveis;

Implementar autenticação/autorização: apenas o dono pode editar ou excluir seu imóvel;

Criar validações de dados (campos obrigatórios, preço numérico, limite de fotos);

Interface para formulário de cadastro;

Interface de visualização detalhada do imóvel;

Interface de edição (formulário com dados pré-preenchidos).

**SPRINT 03 - Refatorar organização e planejamento do projeto**

Acreditamos que será necessário remodelar a maneira com que pensamos no projeto Quartinho, e como devemos prosseguir no desenvolvimento dele. Anteriormente, tínhamos nos dividido entre time backend e time backend, mas observamos que nessa semana essa divisão se provou contra-intuitiva e prejudicou o desenvolvimento do projeto. Desta forma, pretendemos reavaliar e reestruturar o projeto de maneira mais justa e eficiente, a fim de facilitar o processo de desenvolvimento e aprendizagem.

Nesta nova abordagem, todos os integrantes do grupo estarão envolvidos igualmente em todas as etapas do processo: todos deverão contribuir no back, front e revisão igualmente, em todos os seus requisitos funcionais. 

**REQUISITOS FUNCIONAIS A SEREM DESENVOLVIDOS NESTA SEMANA:**

Valor: eu, como locatário, quero buscar por um imóvel de acordo com as minhas preferências. Eu como inquilino, quero buscar por um imóvel.
**SPRINT 03**
| MEMBRO | FRONTEND| BACKEND |
| Hátilan | Perfil do usuário | - |
| João Victor | Favoritos | Favoritos|
| Laura | Tela principal + tela de busca | - |
| Sophia | Detalhes do imóvel | Detalhes do imóvel |
| Vinícius | - | Componente de busca avançada |


**SPRINT 04**
**Objetivo:** implementar o chat entre usuários, sistema de notificações automáticas e páginas detalhadas dos imóveis, conectando os módulos já desenvolvidos.

| Membro          | Atribuições Frontend                                                                                                                                | Atribuições Backend                                                                                                     |
| --------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Sophia**      | Implementar **tela de detalhes do imóvel** (descrição, fotos, regras da casa, contato via chat); integrar com backend para exibir dados atualizados | Criar **endpoint de detalhes do imóvel**; aprimorar respostas da API com dados do dono, fotos e status                  |
| **Laura**       | Desenvolver **interface de chat** (lista de conversas e mensagens em tempo real); criar layout de visualização detalhada do imóvel                  | Integrar **chat mobile** com WebSocket e endpoints REST; implementar **notificações push** no app                       |
| **Vinícius**    | —                                                                                                                                                   | Modelar **entidade de mensagem (chat)**; criar **endpoints REST e WebSocket**; integrar com usuários e imóveis          |
| **João Victor** | —                                                                                                                                                   | Implementar **sistema de notificações automáticas** (nova mensagem, atualização de imóvel); criar **rotina de alertas** |
| **Hátilan**     | Ajustar **sincronia entre módulos web e mobile**; revisar integração de notificações                                                                | Executar **testes de integração** do chat e notificações entre plataformas                                              |
