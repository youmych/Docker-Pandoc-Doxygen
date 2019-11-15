FROM ubuntu:18.04 as build

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/99local && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/99local && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        texlive-full \
        ghostscript \
        librsvg2-2 \
        ttf-dejavu \
        libarchive-tools \
        make \
        wget \
        git && \
    mkdir -p /tmp/packages/tex && \
    cd /tmp/packages/tex && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/csquotes.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/mdframed.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/makecmds.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/filecontents.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/needspace.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/titlesec.zip | bsdtar -xvf - && \
    wget -qO- http://ctan.mirrors.hoobly.com/macros/latex/contrib/titling.zip | bsdtar -xvf - && \
#    wget -qO- http://mirror.hmc.edu/ctan//fonts/psfonts/ly1.zip | bsdtar -xvf - && \
    wget http://mirrors.ctan.org/macros/latex/contrib/etoolbox/etoolbox.sty && \
    wget http://ctan.mirrors.hoobly.com/macros/latex/contrib/mweights/mweights.sty && \
    git clone https://github.com/silkeh/latex-sourcesanspro.git /tmp/sourcesanspro && \
    rm -rf /tmp/sourcesanspro/doc /tmp/sourcesanspro/.git && \
    mv /tmp/sourcesanspro/tex/* /tmp/packages/tex/ && \
    mv /tmp/sourcesanspro/fonts /tmp/packages/ && \
    cd /tmp && \
    wget -qO- http://mirrors.ctan.org/fonts/sourcecodepro.zip | bsdtar -xvf - && \
    mv sourcecodepro/tex/* /tmp/packages/tex && \
    mkdir -p /tmp/packages/fonts/tfm/sourcecodepro && \
    mkdir -p /tmp/packages/fonts/enc/dvips/sourcecodepro && \
    mkdir -p /tmp/packages/fonts/map/dvips/sourcecodepro && \
    mkdir -p /tmp/packages/fonts/opentype/sourcecodepro && \
    mkdir -p /tmp/packages/fonts/type1/sourcecodepro && \
    mkdir -p /tmp/packages/fonts/vf/sourcecodepro && \
    mv sourcecodepro/fonts/SourceCodePro*.tfm /tmp/packages/fonts/tfm/sourcecodepro && \
    mv sourcecodepro/fonts/*.enc /tmp/packages/fonts/enc/dvips/sourcecodepro && \
    mv sourcecodepro/fonts/SourceCodePro.map /tmp/packages/fonts/map/dvips/sourcecodepro && \
    mv sourcecodepro/fonts/SourceCodePro*.otf /tmp/packages/fonts/opentype/sourcecodepro && \
    mv sourcecodepro/fonts/SourceCodePro*.pfb /tmp/packages/fonts/type1/sourcecodepro && \
    mv sourcecodepro/fonts/SourceCodePro*.vf /tmp/packages/fonts/vf/sourcecodepro && \
    cd /tmp/packages/tex/makecmds/ && \
    latex makecmds.ins && \
    cd /tmp/packages/tex/mdframed/ && \
    make all && \
    cd /tmp/packages/tex/filecontents && \
    latex filecontents.ins && \
    cd /tmp/packages/tex/titling && \
    latex titling.ins

FROM ubuntu:18.04

ARG BUILD_DATE
ARG VCS_REF
ARG user
ARG uid

ENV PANDOC_VERSION="2.7.3"

LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Pandoc" \
      org.label-schema.description="Pandoc container including PDFLaTeX to build PDFs from Markdown and Doxygen with Graphviz. And.... cmake!" \
      org.label-schema.url="https://github.com/youmych/Docker-Pandoc-Doxygen" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/youmych/Docker-Pandoc-Doxygen" \
      org.label-schema.vendor="youmych" \
      org.label-schema.version=$PANDOC_VERSION \
      org.label-schema.schema-version="1.0" \
      maintainer="youmych@yandex.ru"

COPY --from=build /tmp/packages /usr/share/texmf-var

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/99local && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/99local && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y apt-utils && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
            texlive-full \                                                         
            ghostscript \
            librsvg2-2 \
            ttf-dejavu \
            doxygen \
            graphviz \
            make \
            cmake \
            wget \
            git && \
#    useradd -ms /bin/bash -u $uid $user && \
    wget -P /tmp https://github.com/jgm/pandoc/releases/download/${PANDOC_VERSION}/pandoc-${PANDOC_VERSION}-linux.tar.gz && \
    tar -xf /tmp/pandoc-${PANDOC_VERSION}-linux.tar.gz -C /tmp && \
    mv /tmp/pandoc-${PANDOC_VERSION}/bin/* /usr/bin/ && \
    texhash /usr/share/texmf-var && \
    cd /usr/share/texmf-var/tex/needspace && \
    pdflatex needspace.tex && \
    mktexlsr && \
    texhash /usr/share/texmf-var && \
    apt-get -y clean && \                                                       
    rm -rf /tmp/* /var/tmp/* /var/cache/apt/archives/* && \                                                
    mkdir -p /opt/project                                                   

CMD [ "/bin/sh" ]

#USER $user
WORKDIR /opt/project
