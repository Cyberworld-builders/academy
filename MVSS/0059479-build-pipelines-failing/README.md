# MVSS-0059479 | Build pipelines failing #60

## Installing SSL Certs on a Windows Server

To set up an SSL certificate on a Windows server, follow these steps:

### Step 1: Generate a Certificate Signing Request (CSR)

1. **Open IIS Manager:**
   - Go to `Start` > `Control Panel` > `Administrative Tools` > `Internet Information Services (IIS) Manager`.

2. **Create a CSR:**
   - In IIS Manager, select your server from the Connections pane.
   - Double-click on `Server Certificates`.
   - Click on `Create Certificate Request...` in the Actions pane.
   - Fill out the form with your organization's details:
     - Common Name (the domain name you want to secure)
     - Organization, Organizational Unit, City/Locality, State/Province, and Country/Region
   - Select a Cryptographic Service Provider (like Microsoft RSA SChannel Cryptographic Provider) with at least 2048-bit key length.
   - Save the CSR to a file.

### Step 2: Purchase the SSL Certificate

- Use the generated CSR to purchase an SSL certificate from a Certificate Authority (CA). You can often copy and paste the contents of the .csr file into the CA's form when ordering.

### Step 3: Install the SSL Certificate

1. **Complete the Certificate Request:**
   - In IIS Manager, again under `Server Certificates`, click `Complete Certificate Request...` in the Actions pane.
   - Browse to where you saved the certificate file provided by your CA (usually with a .cer extension).
   - Give the certificate a friendly name (like the domain name) for easy identification.

2. **Import Intermediate Certificates (if necessary):**
   - If your CA provides intermediate certificates, these need to be installed. 
   - Follow similar steps in IIS Manager but use the `Import...` option instead, selecting the intermediate certificate files.

### Step 4: Bind the Certificate to Your Website

1. **Open Site Bindings:**
   - In IIS Manager, expand the Sites node, select your website.
   - Click `Bindings...` in the Actions pane.

2. **Add HTTPS Binding:**
   - Click `Add...` in the Site Bindings window.
   - Choose `https` as the Type.
   - Select the IP address or leave it to All Unassigned.
   - Set the port to 443 (default for HTTPS).
   - From the SSL Certificate dropdown, select your newly installed certificate.
   - If you have multiple domains or need SNI (Server Name Indication), configure accordingly.

### Step 5: Verify Installation

- Use an SSL checker tool online to verify that your SSL certificate is installed correctly. You can also check by accessing your site via HTTPS in a browser and looking for the lock icon.

### Additional Notes:

- **Automated Tools:** For automated SSL certificate management, tools like Certbot or scripts that integrate with Let's Encrypt can be used, although this is more common on Linux servers. For Windows, third-party tools or scripts might be necessary.
  
- **Self-Signed Certificates:** If you're setting up for testing or internal use, you could create a self-signed certificate using tools like OpenSSL or through IIS for self-signed certificates. However, these are not trusted by default by browsers for public websites.

- **SSL/TLS Configuration:** Ensure your server's SSL/TLS settings are optimized. IIS has settings for SSL/TLS versions and cipher suites which should be configured for security best practices.

By following these steps, you'll have an SSL certificate installed and your site secured with HTTPS. Remember, certificate management includes renewals, so plan for that in advance or use automation for renewal where possible.

---

Here are steps to troubleshoot and resolve SSL verification issues when accessing a Git repository from Azure Pipelines on a Windows Server 2012 environment:

### Understanding the Issue

- **Public Domain but VPN Access:** Your Git server uses a public domain, but the actual access to the repo is restricted by VPN, suggesting that the certificate might not be signed by a commonly trusted CA, or there could be issues with certificate chain validation.

- **SSL Verification Error:** This indicates that the client (in this case, Azure Pipelines) is not trusting the SSL certificate of your Git server. This can happen due to several reasons:
  - Self-signed certificate or certificate from an internal CA.
  - Missing intermediate certificates.
  - Certificate not installed in the correct certificate store or not trusted by the system.

### Troubleshooting Steps:

1. **Verify Certificate Setup:**
   - **Certificate Trust:** Ensure the SSL certificate is trusted by the server where Azure Pipelines runs. 
     - Check if the server's certificate store trusts the CA that issued your SSL certificate. If it's self-signed or from an internal CA, you might need to manually trust it:
       - Open `certlm.msc` to view the Local Machine certificate store.
       - Navigate to `Trusted Root Certification Authorities` for root certificates or `Intermediate Certification Authorities` for intermediate certificates.
       - If necessary, import your certificate or CA's certificates here.

   - **Certificate Path:** Ensure the certificate chain is complete. Sometimes, missing intermediate certificates can cause verification issues.

2. **Git Configuration for SSL:**
   - If the certificate isn't universally trusted, you might configure Git to use the correct CA bundle:
     ```bash
     git config --global http.sslCAInfo "path\to\your\certificate.pem"
     ```
     Replace `"path\to\your\certificate.pem"` with the path to the CA certificate or your server's certificate if it's self-signed.

   - Alternatively, to use Windows' certificate store:
     ```bash
     git config --global http.sslbackend schannel
     ```
     This tells Git to use Windows' certificate validation, which should trust certificates in the Windows certificate store.

3. **Azure Pipelines Agent Configuration:**
   - Ensure the Azure Pipelines agent is configured to use the system's trust store. If you're using a self-signed certificate or one from an internal CA, you need to add this certificate to the agent's machine certificate store.

   - For Azure Pipelines, you can set up a variable for the agent to use:
     ```yaml
     variables:
       GIT_SSL_CAINFO: 'C:\path\to\your\certificate.pem'
     ```
     Or for using the system store:
     ```yaml
     variables:
       GIT_SSL_BACKEND: 'schannel'
     ```

4. **Testing with Verbose Git Commands:**
   - Run Git commands with verbose output to understand where the SSL issue occurs:
     ```bash
     GIT_CURL_VERBOSE=1 git fetch
     ```
   - This command can help identify if the issue is with certificate trust or chain validation.

5. **Temporary Workaround:**
   - If you're troubleshooting, disabling SSL verification can be a temporary measure:
     ```bash
     git -c http.sslVerify=false fetch
     ```
     However, this should not be used in production as it compromises security.

6. **Update or Reconfigure Azure Pipelines:**
   - Depending on how old your Azure Pipelines version is, there might be updates or newer versions that handle SSL better or have different configuration options.

### Final Considerations:
- **Security:** Always ensure that disabling or bypassing SSL verification is only used for troubleshooting. In production, secure configurations should be maintained.
- **Documentation:** If this setup works, document the steps for future reference or for when certificates need renewal.
- **Automation:** Consider automating certificate management, especially if using self-signed or internal CA certificates, to ensure they are properly installed and trusted across all necessary systems.

This approach should help you resolve or at least diagnose the SSL verification issues in your Azure Pipelines setup.