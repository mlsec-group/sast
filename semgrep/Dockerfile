FROM debian:bookworm

ENV SEMGREP_RULES_COMMIT=1e167a89741f2e61c791b381afe72414fb11beb5
ENV CPPCHECK_COMMIT=f4cfed674c20e6991e3726b7e275cf96fc965b29

RUN apt-get update && \
	apt-get install -y git vim python3 python3-pip

RUN pip3 install --break-system-packages semgrep==1.103.0

RUN git clone https://github.com/0xdea/semgrep-rules.git && \
	cd semgrep-rules && \
	git checkout ${SEMGREP_RULES_COMMIT} && \
	echo ".github/" > .semgrepignore

RUN git clone https://github.com/danmar/cppcheck.git cppcheck && \
	cd cppcheck && \
	git checkout $CPPCHECK_COMMIT

COPY execute.sh /usr/local/bin

ENTRYPOINT ["execute.sh"]
