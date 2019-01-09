.PHONY: public
public:
	printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"
	hugo
	cd public && \
	git add . && \
	git commit -m "Deploy website" && \
	git push && \
	cd ..
