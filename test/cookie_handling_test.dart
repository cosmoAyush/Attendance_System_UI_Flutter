import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_system_hris/core/network/dio_client.dart';

void main() {
  group('JWT Token Handling Tests', () {
    test('should set and retrieve JWT token correctly', () {
      // Clear any existing JWT token
      DioClient.clearJwtToken();
      
      // Test JWT token setting
      const testJwt = 'test.jwt.token.here';
      DioClient.setJwtToken(testJwt);
      
      // Verify token exists
      final hasJwtToken = DioClient.hasJwtToken();
      expect(hasJwtToken, true);
      
      // Get token and verify
      final jwtToken = DioClient.getJwtToken();
      expect(jwtToken, testJwt);
    });

    test('should clear JWT token correctly', () {
      // Set a test token
      DioClient.setJwtToken('test.jwt.token');
      
      // Verify token exists
      final hasJwtToken = DioClient.hasJwtToken();
      expect(hasJwtToken, true);
      
      // Clear token
      DioClient.clearJwtToken();
      
      // Verify token is cleared
      final hasJwtTokenAfterClear = DioClient.hasJwtToken();
      expect(hasJwtTokenAfterClear, false);
      
      final jwtToken = DioClient.getJwtToken();
      expect(jwtToken, null);
    });

    test('should handle empty JWT token correctly', () {
      // Clear any existing token
      DioClient.clearJwtToken();
      
      // Test with empty token
      DioClient.setJwtToken('');
      
      // Verify empty token is not considered valid
      final hasJwtToken = DioClient.hasJwtToken();
      expect(hasJwtToken, false);
      
      // Test with null token
      DioClient.clearJwtToken();
      final hasJwtTokenNull = DioClient.hasJwtToken();
      expect(hasJwtTokenNull, false);
    });

    test('should handle token replacement correctly', () {
      // Clear existing token
      DioClient.clearJwtToken();
      
      // Set first token
      DioClient.setJwtToken('jwt.token.1');
      expect(DioClient.getJwtToken(), 'jwt.token.1');
      
      // Replace with second token
      DioClient.setJwtToken('jwt.token.2');
      expect(DioClient.getJwtToken(), 'jwt.token.2');
      
      // Verify only the latest token is stored
      final hasJwtToken = DioClient.hasJwtToken();
      expect(hasJwtToken, true);
      expect(DioClient.getJwtToken(), 'jwt.token.2');
    });
  });
} 