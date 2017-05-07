#!/bin/bash
aws iam upload-server-certificate --server-certificate-name tsk --certificate-body file://cert.pem --private-key file://privkey.pem --certificate-chain file://chain.pem --path /cloudfront/EMKZIBD9EO2FX/
aws iam upload-server-certificate --server-certificate-name tsk1 --certificate-body file://cert.pem --private-key file://key.pem --path /cloudfront/EMKZIBD9EO2FX/
