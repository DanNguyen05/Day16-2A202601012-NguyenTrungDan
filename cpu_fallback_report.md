# CPU Fallback Report

Do GPU quota cho instance `g4dn.xlarge` chua duoc duyet kip thoi gian lam lab, em su dung phuong an du phong CPU voi instance `r5.2xlarge`.
Dataset duoc su dung la Credit Card Fraud Detection tu Kaggle, gom 284,807 giao dich.
Thoi gian load data dat 1.62 giay va thoi gian training LightGBM dat 3.63 giay.
Mo hinh dat AUC-ROC 0.9698, Accuracy 0.99956 va F1-Score 0.8677.
Precision dat 0.9011 va Recall dat 0.8367, cho thay mo hinh phat hien fraud kha tot tren du lieu mat can bang.
Inference latency cho 1 row la 0.0016 giay, rat nhanh cho tac vu scoring rieng le.
Inference voi 1000 rows mat 0.00445 giay, cho thay throughput tot tren CPU.
So voi phuong an GPU LLM, phuong an CPU khong chay Gemma/vLLM nhung van hoan thanh quy trinh Terraform, cloud instance, training, inference va billing check.
Sau khi chup screenshot benchmark va AWS Billing, em da/chuan bi chay `terraform destroy` de tranh phat sinh chi phi.
