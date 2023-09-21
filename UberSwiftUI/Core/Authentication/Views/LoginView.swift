//
//  LoginView.swift
//  UberSwiftUI
//
//  Created by Marcos Michel on 21/09/23.
//

import SwiftUI

struct LoginView: View {
    
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            VStack {
                
                // image and title
                
                VStack(spacing: -16) {
                    // image
                    
                    Image("uber-app-icon")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .background()
                        .padding(.top)
                    
                    // title
                    Text("UBER")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
                // input fields
                
                VStack(spacing: 32) {
                    
                    VStack(alignment: .leading) {
                        Text("Email Address")
                            .fontWeight(.semibold)
                            .font(.footnote)
                        
                        TextField("name@example.com", text: $email)
                            .keyboardType(.emailAddress)
                        
                        Rectangle()
                            .foregroundColor(Color(.init(white: 1, alpha: 0.3)))
                            .frame(width: UIScreen.main.bounds.width - 32, height: 0.7)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Password")
                            .fontWeight(.semibold)
                            .font(.footnote)
                        
                        TextField("Enter your password", text: $password)
                        
                        Rectangle()
                            .foregroundColor(Color(.init(white: 1, alpha: 0.3)))
                            .frame(width: UIScreen.main.bounds.width - 32, height: 0.7)
                    }
                    
                    Button {
                        //
                    } label: {
                        Text("Forgot Password?")
                            .font(.system(size: 13, weight: .semibold))
                            .padding(.top)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // social sign in view
                
                VStack {
                    
                    HStack(spacing: 24) {
                        Rectangle()
                            .frame(width: 76, height: 1)
                            .opacity(0.5)
                        
                        Text("Sign in with social")
                            .fontWeight(.semibold)
                        
                        Rectangle()
                            .frame(width: 76, height: 1)
                            .opacity(0.5)
                    }
                    
                    HStack(spacing: 24) {
                        
                        Button {
                            
                        } label: {
                            Image("facebook")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }

                        
                        Button {
                            
                        } label: {
                            Image("google")
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                        
                    }
                }
                .padding(.vertical)
                
                Spacer()
                
                // sign in button
                
                Button {
                    
                } label: {
                    HStack {
                        Text("SIGN IN")
                            
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                }
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                .background()
                .cornerRadius(10)

                
                // sign up button
                
                Button {
                    
                } label: {
                    HStack {
                        Text("Don't hava an account?")
                            .font(.system(size: 14))
                        
                        Text("Sign Up")
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .padding(.top, 32)

            }
        }
        .foregroundColor(.white)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
