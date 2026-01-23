#!/bin/bash
# Template: Initialize typeCAD project with isolated build directory
# Usage: ./init-typecad-project.sh <project-name>

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <project-name>"
    exit 1
fi

PROJECT_NAME="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🚀 Initializing typeCAD project: $PROJECT_NAME"

# 1. Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# 2. Create src directory
mkdir -p src

# 3. Create build directory with diagrams subdirectory
mkdir -p build/diagrams

# 4. Link shared resources
echo "  Linking shared resources..."
ln -s ../build/footprints build/footprints
ln -s ../build/lib build/lib

# 5. Create package.json
cat > package.json << 'EOF'
{
  "name": "PROJECT_NAME_PLACEHOLDER",
  "version": "1.0.0",
  "scripts": {
    "build": "tsx src/index.ts"
  },
  "dependencies": {
    "@typecad/typecad": "latest",
    "@typecad/passives": "latest"
  },
  "devDependencies": {
    "tsx": "latest",
    "typescript": "latest"
  }
}
EOF

# Replace placeholder
sed -i '' "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" package.json

# 6. Create tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  }
}
EOF

# 7. Create basic index.ts
cat > src/index.ts << 'EOF'
import { PCB } from '@typecad/typecad';

let typecad = new PCB('PROJECT_NAME_PLACEHOLDER');

// Add components and connections here

typecad.create();
EOF

# Replace placeholder
sed -i '' "s/PROJECT_NAME_PLACEHOLDER/$PROJECT_NAME/g" src/index.ts

echo ""
echo "✅ Project initialized: $PROJECT_NAME"
echo ""
echo "Next steps:"
echo "  cd $PROJECT_NAME"
echo "  npm install"
echo "  npm run build"
