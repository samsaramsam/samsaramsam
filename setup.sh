#!/bin/bash

# Online Ordering App Setup Script

echo "Setting up Online Ordering App..."

# Create project directory
mkdir online-ordering-app
cd online-ordering-app

# Backend setup
echo "Setting up backend..."
mkdir backend
cd backend
npm init -y
npm install express mongoose cors dotenv bcryptjs jsonwebtoken

cat << EOF > server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true });

const productSchema = new mongoose.Schema({
  name: String,
  description: String,
  price: Number,
  category: String
});

const Product = mongoose.model('Product', productSchema);

app.get('/api/products', async (req, res) => {
  const products = await Product.find();
  res.json(products);
});

app.post('/api/orders', (req, res) => {
  // Implement order processing logic here
  res.json({ message: 'Order received', orderId: Date.now() });
});

app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));
EOF

echo "MONGODB_URI=mongodb://localhost:27017/online-ordering" > .env

cd ..

# Frontend setup (React Native)
echo "Setting up frontend (React Native)..."
npx react-native init OnlineOrderingApp
cd OnlineOrderingApp
npm install @react-navigation/native @react-navigation/stack axios
npm install react-native-reanimated react-native-gesture-handler react-native-screens react-native-safe-area-context @react-native-community/masked-view

# Replace App.js with a basic structure
cat << EOF > App.js
import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import ProductList from './src/screens/ProductList';
import OrderScreen from './src/screens/OrderScreen';

const Stack = createStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Products" component={ProductList} />
        <Stack.Screen name="Order" component={OrderScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
EOF

# Create screens directory
mkdir -p src/screens

# Create ProductList screen
cat << EOF > src/screens/ProductList.js
import React, { useState, useEffect } from 'react';
import { View, Text, FlatList, TouchableOpacity, StyleSheet } from 'react-native';
import axios from 'axios';

function ProductList({ navigation }) {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    axios.get('http://localhost:5000/api/products')
      .then(response => setProducts(response.data))
      .catch(error => console.error('Error fetching products:', error));
  }, []);

  return (
    <View style={styles.container}>
      <FlatList
        data={products}
        keyExtractor={item => item._id}
        renderItem={({ item }) => (
          <TouchableOpacity
            style={styles.item}
            onPress={() => navigation.navigate('Order', { product: item })}
          >
            <Text>{item.name} - ${item.price}</Text>
          </TouchableOpacity>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    paddingTop: 22
  },
  item: {
    padding: 10,
    fontSize: 18,
    height: 44,
  },
});

export default ProductList;
EOF

# Create OrderScreen
cat << EOF > src/screens/OrderScreen.js
import React, { useState } from 'react';
import { View, Text, TextInput, Button, StyleSheet } from 'react-native';
import axios from 'axios';

function OrderScreen({ route }) {
  const { product } = route.params;
  const [quantity, setQuantity] = useState('1');

  const handleOrder = () => {
    axios.post('http://localhost:5000/api/orders', { productId: product._id, quantity: parseInt(quantity) })
      .then(response => alert(\`Order placed successfully. Order ID: \${response.data.orderId}\`))
      .catch(error => console.error('Error placing order:', error));
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{product.name}</Text>
      <Text>Price: ${product.price}</Text>
      <TextInput
        style={styles.input}
        onChangeText={setQuantity}
        value={quantity}
        keyboardType="numeric"
      />
      <Button title="Place Order" onPress={handleOrder} />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
  },
  input: {
    height: 40,
    borderColor: 'gray',
    borderWidth: 1,
    marginTop: 20,
    marginBottom: 20,
    paddingHorizontal: 10,
  },
});

export default OrderScreen;
EOF

cd ..

echo "Setup complete! To start the application:"
echo "1. Start MongoDB"
echo "2. cd backend && npm start"
echo "3. cd OnlineOrderingApp && npx react-native run-android (or run-ios)"
