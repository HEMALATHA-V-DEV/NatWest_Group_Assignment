# AWS & CSV Python Analyzer

This repository contains two Python scripts:

1. **s3_bucket_info.py**: Lists all S3 buckets and shows the number of objects in a specified bucket.
2. **student_grade_analysis.py**: Analyzes a CSV file and prints names of students with average grades above a threshold.

---

## 🔧 Setup

Install AWS SDK:

```
pip install boto3
```

```
aws configure
```

Run s3_bucket_info.py: List S3 Buckets & Count Objects

S3 Buckets:
 - my-first-bucket
 - logs-bucket
Enter the bucket name to count objects: my-first-bucket
Total number of objects in bucket 'my-first-bucket': 42


Run student_grade_analysis.py: Analyze Student Grades from CSV
Enter path to the CSV file: students.csv
Enter grade threshold: 85
Charlie - Average Grade: 90.67
Alice - Average Grade: 89.0


### Push to GitHub

```
git add .
git commit -m "Initial commit: AWS SDK and CSV analysis scripts"
git push origin main
```

