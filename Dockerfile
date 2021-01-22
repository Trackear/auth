FROM elixir:1.11

ENV NODE_VERSION v14.15.4
ENV NVM_DIR /usr/local/nvm
ENV NODE_PATH $NVM_DIR/$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

RUN mkdir $NVM_DIR
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN echo "source $NVM_DIR/nvm.sh && \
    nvm install $NODE_VERSION && \
    nvm alias default $NODE_VERSION && \
    nvm use default" | bash

RUN mkdir /app
WORKDIR /app

COPY mix.exs ./
COPY mix.lock ./

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get && \
    mix deps.compile

COPY . ./

EXPOSE 5000
CMD ["sh", "./run.sh"]