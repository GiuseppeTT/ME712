.PHONY: \
	dependencies \
	drake \
	clean

dependencies:
	Rscript -e "if(! 'renv' %in% installed.packages()[, 'Package']) install.packages('renv')"
	Rscript -e "renv::restore()"

drake:
	Rscript -e "drake::r_make()"

clean:
	Rscript -e "drake::clean(destroy = TRUE)"
