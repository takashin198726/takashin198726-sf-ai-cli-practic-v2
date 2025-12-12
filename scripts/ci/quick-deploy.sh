#!/bin/bash
set -e

VALIDATION_ID_FILE=".validation-id"

# Usage function
usage() {
  echo "Usage: $0 [save <validation-id> | deploy]"
  echo ""
  echo "Commands:"
  echo "  save <validation-id>  Save validation ID for later quick deploy"
  echo "  deploy                Execute quick deploy using saved validation ID"
  exit 1
}

# Save validation ID
if [ "$1" == "save" ]; then
  if [ -z "$2" ]; then
    echo "❌ Error: Validation ID required"
    usage
  fi
  
  echo "$2" > "$VALIDATION_ID_FILE"
  echo "✅ Validation ID saved: $2"
  echo "📝 Valid for 10 days from validation completion"
  exit 0
fi

# Quick deploy
if [ "$1" == "deploy" ] || [ -z "$1" ]; then
  if [ ! -f "$VALIDATION_ID_FILE" ]; then
    echo "❌ No validation ID found. Run validation first."
    echo ""
    echo "To save a validation ID:"
    echo "  $0 save <validation-id>"
    exit 1
  fi
  
  VALIDATION_ID=$(cat "$VALIDATION_ID_FILE")
  echo "🚀 Quick deploying with validation ID: $VALIDATION_ID"
  echo "⏱️  Starting deployment..."
  
  START_TIME=$(date +%s)
  
  # Execute quick deploy
  sf project deploy quick \
    --job-id "$VALIDATION_ID" \
    --wait 10 \
    --verbose || {
      echo ""
      echo "❌ Quick deploy failed"
      echo "💡 Possible reasons:"
      echo "   - Validation ID expired (>10 days old)"
      echo "   - Target org metadata changed since validation"
      echo "   - Another deployment occurred after validation"
      echo ""
      echo "Solution: Run a new validation and save the ID"
      exit 1
    }
  
  END_TIME=$(date +%s)
  DURATION=$((END_TIME - START_TIME))
  MINUTES=$((DURATION / 60))
  SECONDS=$((DURATION % 60))
  
  echo ""
  echo "✅ Quick deploy completed successfully!"
  echo "⏱️  Total time: ${MINUTES}m ${SECONDS}s"
  echo "🎉 Saved approximately $(( $((30 * 60)) - DURATION ))s compared to full deployment"
  
  exit 0
fi

# Invalid command
echo "❌ Invalid command: $1"
usage
