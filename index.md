### Overview
Separating user requirements from the implementation details has the potential of changing the way IT systems are deployed and managed in the cloud. To capture user requirements, we developed a high-level abstraction called the requirement model for defining cloud-based IT systems. Once users define their desired system in the specification, it is automatically compiled into a concrete cloud-based system that meets the specified user requirements. We demonstrate the practicality of this approach in the **ANCOR** framework.

ANCOR is a cloud automation framework that models dependencies between different layers in an application stack. When instances in one layer changes, the instances in a dependent layer are notified and reconfigured.

More details: [Compiling Abstract Specifications into Concrete Systems – Bringing Order to the Cloud](http://people.cis.ksu.edu/~bardasag/paper.pdf)

### Overall Picture
Currently, there are important limitations in the abstractions that support creating and managing services in a cloud-based IT system. As a result, cloud users must choose between managing the low-level details of their cloud services directly (as in IaaS), which is time- consuming and error-prone, and turning over significant parts of this management to their cloud provider (in SaaS or PaaS), which is less flexible and more difficult to tailor to user needs. 

To alleviate this situation we propose a high-level abstraction called the requirement model for defining cloud-based IT systems. It captures important aspects of a system’s structure, such as service dependencies, without introducing low-level details such as operating systems or application configurations. The requirement model separates the cloud customer’s concern of what the system does, from the system engineer’s concern of how to implement it. 

In addition, we present a “compilation” process that automatically translates a requirement model into a concrete system based on pre-defined and reusable knowledge units. When combined, the requirement model and the compilation process enable repeatable deployment of cloud- based systems, more reliable system management, and the ability to implement the same requirement in different ways and on multiple cloud platforms. 

We demonstrate the practicality of this approach in the ANCOR (Automated eNterprise network COmpileR) framework, which generates concrete, cloud-based systems based on a specific requirement model. Our current implementation targets OpenStack and uses Puppet to configure the cloud instances, although the framework will also support other cloud platforms and configuration management solutions.

### Authors and Contributors
* Ian Unruh (@ianunruh)
* Alex Bardas (@bardasag)
* Rui Zhuang (@zrui)
* Xinming Ou (@xinmingou)
* Scott A. DeLoach

### Support or Contact
Please contact ArgusLab group members for more information http://arguslab.org or contact iunruh@ksu.edu, bardasag@ksu.edu and we will be happy to help you out.

More setup information will be made available on the GitHub file repository page.

### License
This program is free software and it is distributed under the [GNU General Public License](http://people.cis.ksu.edu/~bardasag/ANCOR%20Copyright%20and%20License.txt) terms.
