# Gets the docker image for perl 5.28
FROM perl:5.28

# Install all missing perl modules
RUN cpanm Log::Any && \  
    cpanm Log::Any::Adapter::Dispatch && \ 
    cpanm Log::Log4perl && \ 
    cpanm Log::Any::Adapter::Log4perl && \ 
    cpanm Const::Fast && \ 
    cpanm IPC::Run && \ 
    cpanm LWP::Simple && \ 
    cpanm Archive::Extract && \ 
    cpanm File::Slurper && \ 
    cpanm File::Copy::Recursive

# Move the code of the repo to the container under /mini-magic
WORKDIR /mini-magic
COPY . .

# Download Magdir
RUN perl bin/mini-magic -d 

ENTRYPOINT [ "perl", "bin/mini-magic"]