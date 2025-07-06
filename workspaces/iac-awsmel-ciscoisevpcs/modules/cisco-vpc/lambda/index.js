 exports.handler = async (event) => {
      console.log('Cisco ISE handler invoked');
      return {
        statusCode: 200,
        body: JSON.stringify('Hello from Lambda!'),
      };
    };