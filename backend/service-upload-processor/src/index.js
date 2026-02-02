const express = require("express");
const app = express();
const port = process.env.PORT || 8080;

app.use(express.json({ limit: "10mb" }));

// Health check
app.get("/health", (req, res) => {
  console.log("Health check pinged");
  res.status(200).send("OK - upload-processor is alive 🚀");
});


// Pub/Sub push endpoint 
app.post("/process-image", (req, res) => {
  console.log("╔════════════════════════════════════════════╗");
  console.log("║     PUB/SUB PUSH MESSAGE RECEIVED!         ║");
  console.log("╚════════════════════════════════════════════╝");

  console.log("Full body:", JSON.stringify(req.body, null, 2));

  if (req.body.message && req.body.message.data) {
    const decoded = Buffer.from(req.body.message.data, "base64").toString();
    console.log("Decoded message:", decoded);

    try {
      const event = JSON.parse(decoded);
      console.log("Parsed event:", JSON.stringify(event, null, 2));

      console.log("Bucket:", event.bucket);
      console.log("File path:", event.name);
      console.log("requestId:", event.metadata?.requestId || "not found");
      console.log("Upload time:", event.metadata?.uploadTime || "not found");
    } catch (e) {
      console.error("Parse error:", e);
    }
  } else {
    console.log("No valid Pub/Sub message");
  }

  // MUST return 204 to acknowledge
  res.status(204).send();
});

app.listen(port, () => {
  console.log(`Service upload-processor running on port ${port}`);
});
