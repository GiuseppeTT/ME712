# https://hub.docker.com/r/rocker/tidyverse
# Contains:
# - Debian
# - R
# - Rstudio
# - tidyverse
FROM rocker/tidyverse:latest

# Add latex (full = VERY conservative)
RUN true \
    && apt-get update \
    && apt-get install -y texlive-full

# https://github.com/matze/mtheme/issues/280
# Make latex fonts available to the system
# Otherwise latex won't compile with Fira fonts
COPY docker/09-texlive-fonts.conf /etc/fonts/conf.d/09-texlive-fonts.conf
RUN fc-cache

# Add project and install dependencies
RUN true \
    && git clone https://github.com/GiuseppeTT/me712.git home/rstudio/me712 \
    && cd /home/rstudio/me712 \
    && make dependencies

WORKDIR /home/rstudio/me712
