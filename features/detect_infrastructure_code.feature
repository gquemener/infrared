Feature: Detect infrastructure code
  In order to decouple core and infrastructure code
  As a developper
  I need to be able to scan a PHP codebase for infrastructure code usage

  Scenario: Detect curl usage
    Given the following "src/ApiClient.php" file:
    """
    final class ApiClient
    {
      public function fetchData()
      {
        $ch = curl_init('https://example.org');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        return curl_exec($ch);
      }
    }
    """
    When I run the "bin/detect src/"
    Then command should have failed with exit code 1
    And I should see:
    """
    1 violation detected:
    - src/ApiClient.php
      * Access to remote server through curl_* function
    """

  Scenario: Detect PDO usage
    Given the following "src/DTORepository.php" file:
    """
    final class DTORepository
    {
      public function get(string $id): ?DTO
      {
        $pdo = new \PDO('mysql:dbname=testdb;host=127.0.0.1');
        $stmt = $pdo->prepare('SELECT * FROM `dto` WHERE id = ?');
        $stmt->bindValue(1, $id, \PDO::PARAM_STR);
        if (null = $data = $stmt->fetch(\PDO::FETCH_ASSOC)) {
          return null;
        }

        return \DTO::fromData($data);
      }
    }
    """
    When I run the "bin/detect src/"
    Then command should have failed with exit code 1
    And I should see:
    """
    1 violation detected:
    - src/DTORepository.php
      * Access to database through PDO
    """

  Scenario: Detect filesystem access
    Given the following "src/FileDumper.php" file:
    """
    final class FileDumper
    {
      public function dump(string $content): void
      {
        file_put_content('dump', $content);
      }
    }
    """
    When I run the "bin/detect src/" command
    Then command should have failed with exit code 1
    And I should see:
    """
    1 violation detected:
    - src/FileDumper.php
      * Access to filesystem
    """

  Scenario: Detect infrastructure code in vendor
    Given I am located in the "uuid" project
    And I have installed the dependencies
    When I run the "bin/detect src/" command
    Then command should have failed with exit code 1
    And I should see:
    """
    1 violation detected:

    | src/Domain/Entity.php:16                                     | $this->id = Uuid::uuid4();                         |
    | vendor/ramsey/uuid/src/Uuid.php:567                          | $value = $this->randomGenerator->generateNumber(); |
    | vendor/ramsey/uuid/src/Generator/RandomBytesGenerator.php:35 | return random_bytes($length);                      |

    Reason: Call to pseudo random generator
    """
