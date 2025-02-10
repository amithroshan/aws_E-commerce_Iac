const express = require('express');
const path = require('path');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { body, validationResult } = require('express-validator');
const app = express();
const port = 3000;

const AWS = require('aws-sdk');

// Set region, if not already configured via CLI
AWS.config.update({ region: 'us-east-1' }); // Adjust if needed, based on your setup

const dynamoDB = new AWS.DynamoDB.DocumentClient();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json()); 

async function getProducts() {
  const params = {
    TableName: 'products', // DynamoDB table for products
  };

  try {
    const result = await dynamoDB.scan(params).promise(); // Scans the table for all items
    return result.Items; // Return all products
  } catch (error) {
    console.error("Error fetching products:", error);
    return [];
  }
}

app.get('/products', async (req, res) => {
  const products = await getProducts();
  if (products.length === 0) {
    res.status(404).send("No products found.");
  } else {
    res.json(products);
  }
});


app.get('/products', async (req, res) => {
  const products = await getProducts();
  if (products.length === 0) {
    res.status(404).send("No products found.");
  } else {
    res.json(products);
  }
});


app.post(
  '/signup',
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    try {
      const existingUserParams = {
        TableName: 'users',
        Key: { email },
      };

      const existingUser = await dynamoDB.get(existingUserParams).promise();

      if (existingUser.Item) {
        return res.status(400).json({ message: 'User already exists' });
      }

      const hashedPassword = await bcrypt.hash(password, 10);

      const newUser = {
        TableName: 'users',
        Item: {
          email,
          password: hashedPassword,
        },
      };

      await dynamoDB.put(newUser).promise();

      res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
      console.error('Error signing up user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  }
);


app.get('/signup', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'signup.html'));
});


app.post(
  '/login',
  body('email').isEmail().normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required'),
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { email, password } = req.body;

    try {
      const userParams = {
        TableName: 'users',
        Key: { email },
      };

      const user = await dynamoDB.get(userParams).promise();

      if (!user.Item) {
        return res.status(400).json({ message: 'Invalid email or password' });
      }

      const isMatch = await bcrypt.compare(password, user.Item.password);

      if (!isMatch) {
        return res.status(400).json({ message: 'Invalid email or password' });
      }

      const token = jwt.sign({ userId: user.Item.email, email: user.Item.email }, 'your_jwt_secret', { expiresIn: '1h' });

      res.json({ message: 'Login successful', token });
    } catch (error) {
      console.error('Error logging in user:', error);
      res.status(500).json({ message: 'Internal server error' });
    }
  }
);


app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'login.html'));
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

