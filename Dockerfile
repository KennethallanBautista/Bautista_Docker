# Part A: use an official, version-pinned, small Python image.
FROM python:3.12-slim

# Run the SecureNotes API from a consistent working directory.
WORKDIR /app

# Copy the dependency list first to benefit from Docker layer caching.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Add the application source after the dependency layer.
COPY . .

# Part B: don't run the API process as root.
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Make the API accessible through an explicitly published port.
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
