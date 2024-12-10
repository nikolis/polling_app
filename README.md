# PollingApp

### DB Selection
Due to the neture of the app being exclusively as a coding challenge for a software engineering position the desicion was taken to 
use SQLite for easea instead of a full blown DBMS system such as Postgres. 

### Model Design 
The Poll model is the core processing unit of this application. User's in this application create,edit and vote in polls

### Initialization of the project and code generation 
I took the decision to use as much as possible the phoenix generators to kickstart this project even in the places that seem like an overkill. I decide to do that because the generated code is getting more and more sophisticated over version changes and it's a good place to catch up on the best practices and generalize from there when ever possible. 

## Known Issues 
    * The restriction for editing is in the UI layer (Who can edit which poll)


To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
