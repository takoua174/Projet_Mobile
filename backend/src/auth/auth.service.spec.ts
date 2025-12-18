import { Test, TestingModule } from '@nestjs/testing';
import { JwtService } from '@nestjs/jwt';
import { UnauthorizedException, BadRequestException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcryptjs';

describe('AuthService', () => {
  let authService: AuthService;
  let usersService: UsersService;
  let jwtService: JwtService;

  const mockUsersService = {
    findByEmail: jest.fn(),
    findByUsername: jest.fn(),
    create: jest.fn(),
  };

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        {
          provide: UsersService,
          useValue: mockUsersService,
        },
        {
          provide: JwtService,
          useValue: mockJwtService,
        },
      ],
    }).compile();

    authService = module.get<AuthService>(AuthService);
    usersService = module.get<UsersService>(UsersService);
    jwtService = module.get<JwtService>(JwtService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('register', () => {
    it('should successfully register a new user', async () => {
      const registerDto = {
        email: 'test@example.com',
        username: 'testuser',
        password: 'Test123!@#',
      };

      const hashedPassword = await bcrypt.hash(registerDto.password, 12);
      const newUser = {
        id: '123',
        email: registerDto.email,
        username: registerDto.username,
        password: hashedPassword,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUsersService.findByEmail.mockResolvedValue(null);
      mockUsersService.findByUsername.mockResolvedValue(null);
      mockUsersService.create.mockResolvedValue(newUser);
      mockJwtService.sign.mockReturnValue('test-token');

      const result = await authService.register(registerDto);

      expect(result).toEqual({
        access_token: 'test-token',
        user: {
          id: '123',
          email: registerDto.email,
          username: registerDto.username,
        },
      });
      expect(mockUsersService.create).toHaveBeenCalled();
      expect(mockJwtService.sign).toHaveBeenCalled();
    });

    it('should throw BadRequestException if email already exists', async () => {
      const registerDto = {
        email: 'existing@example.com',
        username: 'newuser',
        password: 'Test123!@#',
      };

      mockUsersService.findByEmail.mockResolvedValue({
        id: '123',
        email: registerDto.email,
      });

      await expect(authService.register(registerDto)).rejects.toThrow(
        BadRequestException,
      );
      expect(mockUsersService.create).not.toHaveBeenCalled();
    });

    it('should throw BadRequestException if username already exists', async () => {
      const registerDto = {
        email: 'new@example.com',
        username: 'existinguser',
        password: 'Test123!@#',
      };

      mockUsersService.findByEmail.mockResolvedValue(null);
      mockUsersService.findByUsername.mockResolvedValue({
        id: '123',
        username: registerDto.username,
      });

      await expect(authService.register(registerDto)).rejects.toThrow(
        BadRequestException,
      );
      expect(mockUsersService.create).not.toHaveBeenCalled();
    });
  });

  describe('login', () => {
    it('should successfully login a user', async () => {
      const loginDto = {
        email: 'test@example.com',
        password: 'Test123!@#',
      };

      const hashedPassword = await bcrypt.hash(loginDto.password, 12);
      const user = {
        id: '123',
        email: loginDto.email,
        username: 'testuser',
        password: hashedPassword,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUsersService.findByEmail.mockResolvedValue(user);
      mockJwtService.sign.mockReturnValue('test-token');

      const result = await authService.login(loginDto);

      expect(result).toEqual({
        access_token: 'test-token',
        user: {
          id: '123',
          email: loginDto.email,
          username: 'testuser',
        },
      });
    });

    it('should throw UnauthorizedException for invalid credentials', async () => {
      const loginDto = {
        email: 'test@example.com',
        password: 'WrongPassword123!',
      };

      mockUsersService.findByEmail.mockResolvedValue(null);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it('should throw UnauthorizedException for inactive account', async () => {
      const loginDto = {
        email: 'test@example.com',
        password: 'Test123!@#',
      };

      const user = {
        id: '123',
        email: loginDto.email,
        username: 'testuser',
        password: await bcrypt.hash(loginDto.password, 12),
        isActive: false,
        createdAt: new Date(),
        updatedAt: new Date(),
      };

      mockUsersService.findByEmail.mockResolvedValue(user);

      await expect(authService.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe('validateToken', () => {
    it('should successfully validate a token', async () => {
      const token = 'valid-token';
      const payload = {
        sub: '123',
        email: 'test@example.com',
        username: 'testuser',
      };

      mockJwtService.verify.mockReturnValue(payload);

      const result = await authService.validateToken(token);

      expect(result).toEqual(payload);
      expect(mockJwtService.verify).toHaveBeenCalledWith(token);
    });

    it('should throw UnauthorizedException for invalid token', async () => {
      const token = 'invalid-token';

      mockJwtService.verify.mockImplementation(() => {
        throw new Error('Invalid token');
      });

      await expect(authService.validateToken(token)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });
});
