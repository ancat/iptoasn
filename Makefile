fetch:
	mkdir -p tmp
	wget https://iptoasn.com/data/ip2asn-v4.tsv.gz -P tmp
	gunzip tmp/ip2asn-v4.tsv.gz

process:
	grep -v "Not routed" tmp/ip2asn-v4.tsv > tmp/cleaned_ip2asn.tsv

index:
	ruby build_indexes.rb tmp/cleaned_ip2asn.tsv

clean:
	rm -rf tmp
