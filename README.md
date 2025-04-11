# tf-aws-infra

# import certificates into ACM
aws acm import-certificate \
    --certificate fileb://cert1.pem \
    --private-key fileb://privkey.pem \
    --certificate-chain fileb://chain1.pem \
    --region us-east-1