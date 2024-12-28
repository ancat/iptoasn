fetch:
	mkdir -p tmp
	wget https://iptoasn.com/data/ip2asn-v4.tsv.gz -P tmp
	gunzip tmp/ip2asn-v4.tsv.gz

process:
	grep -v "Not routed" tmp/ip2asn-v4.tsv > tmp/cleaned_ip2asn.tsv
	gsplit -C 1m tmp/cleaned_ip2asn.tsv tmp/chunk_

index:
	ruby build_indexes.rb

clean:
	rm -rf tmp
