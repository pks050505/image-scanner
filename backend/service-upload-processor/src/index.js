const express = require("express");
const { PubSub } = require("@google-cloud/pubsub"); // ← yeh add karo

const app = express();
const port = process.env.PORT || 8080;

app.use(express.json({ limit: "10mb" }));

// Health check
app.get("/health", (req, res) => {
  console.log("Health check pinged");
  res.status(200).send("OK - upload-processor is alive 🚀");
});

// Pub/Sub push endpoint
app.post("/process-image", async (req, res) => {
  // ← async kar do
  console.log("╔════════════════════════════════════════════╗");
  console.log("║     PUB/SUB PUSH MESSAGE RECEIVED!         ║");
  console.log("╚════════════════════════════════════════════╝");

  console.log("Full body:", JSON.stringify(req.body, null, 2));

  let requestId = "unknown";

  if (req.body.message && req.body.message.data) {
    const decoded = Buffer.from(req.body.message.data, "base64").toString();
    console.log("Decoded message:", decoded);

    try {
      const event = JSON.parse(decoded);
      console.log("Parsed event:", JSON.stringify(event, null, 2));

      console.log("Bucket:", event.bucket);
      console.log("File path:", event.name);
      requestId = event.metadata?.requestId || "not-found";
      console.log("requestId:", requestId);
      console.log("Upload time:", event.metadata?.uploadTime || "not found");

      // ← Ab yahan dummy processing complete maan lo (baad mein real OCR yahan aayega)
      const results = {
        requestId: requestId,
        status: "completed",
        processedAt: new Date().toISOString(),
        dishes: [
          {
            name: "Butter Chicken",
            isVeg: false,
            ingredients: ["chicken", "butter"],
          },
          {
            name: "Paneer Tikka",
            isVeg: true,
            ingredients: ["paneer", "spices"],
          },
        ],
      };

      // Publish to results topic
      const pubsub = new PubSub();
      const topic = pubsub.topic("menu-results-topic");

      const dataBuffer = Buffer.from(JSON.stringify(results));

      await topic.publishMessage({ data: dataBuffer });
      console.log(`Results published successfully for requestId: ${requestId}`);
    } catch (e) {
      console.error("Parse or processing error:", e);
    }
  } else {
    console.log("No valid Pub/Sub message");
  }

  // MUST return 204 to acknowledge original message
  res.status(204).send();
});

app.listen(port, () => {
  console.log(`Service upload-processor running on port ${port}`);
});
