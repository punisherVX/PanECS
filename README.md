#**PANDEMONIUM**

--------------
#### <i class="icon-folder"></i> Getting Started with PAN-ELK Stack
Get set up by following instructions in the **readme** file for pan_demon.
You'll need docker for the containers that make up the ELK stack.

It's also recommended that you have a Palo Alto Networks (PAN) Next-Generation Firewall for sending logs to the ELK stack.  For linux users, you can use the **genlog** script for simulating logs should you be absent a PAN Firewall.

----------

#### <i class="icon-file"></i> Getting Started with Demisto Integration
Once you have your ELK stack set up with incoming logs from the PAN NGFW(s), kick it up a notch by integrating Security Orchestration Automation and Response (SOAR) with Palo Alto Network's Demisto Server!
Instructions are included in the **readme** file for demisto_integration.

> **Note:**

> - Ensure all of your data is being type formatted within ELK before integrating with Demisto.
> - Setting up SOAR integration requires initial setup on **both** the ELK side and Demisto server
