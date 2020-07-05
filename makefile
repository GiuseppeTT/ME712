.PHONY: \
	build \
	rstudio \
	docker \
	dependencies \
	drake \
	clean

build:
	docker build -t me712 .
	docker tag me712 giuseppett/me712

bash:
	docker run --rm --name me712 -ti giuseppett/me712 bash

rstudio:
	@echo -n "Make a password for docker rstudio server:" && read -s password && echo \
	&& docker run -d --privileged --rm --name me712 -e PASSWORD=$$password -p 8787:8787 giuseppett/me712 > /dev/null
	@google-chrome http://localhost:8787 &> /dev/null
	@echo -n "Type any key to close rstudio server:" && read -rsn1 && echo
	@docker stop me712 > /dev/null

docker:
	docker run -d --rm --name me712 giuseppett/me712
	docker cp data/Dados_Consultoria.xlsx me712:/home/rstudio/me712/data/Dados_Consultoria.xlsx
	docker exec me712 make drake
	docker cp me712:/home/rstudio/me712/documents/report/report.pdf documents/report/report.pdf
	docker cp me712:/home/rstudio/me712/documents/presentation/presentation.pdf documents/presentation/presentation.pdf
	docker stop me712

dependencies:
	Rscript -e "if(! 'renv' %in% installed.packages()[, 'Package']) install.packages('renv')"
	Rscript -e "renv::restore()"

drake:
	Rscript -e "drake::r_make()"

clean:
	Rscript -e "drake::clean(destroy = TRUE)"
