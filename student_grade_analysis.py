import csv

def analyze_grades(file_path, threshold):
    with open(file_path, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            grades = list(map(float, row['grade'].split(',')))
            average = sum(grades) / len(grades)
            if average > threshold:
                print(f"{row['name']} - Average Grade: {average}")

if __name__ == "__main__":
    csv_file = input("Enter path to the CSV file: ")
    threshold = float(input("Enter grade threshold: "))
    analyze_grades(csv_file, threshold)
