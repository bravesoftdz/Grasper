<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobRuleLinks
 */
class JobRuleLinks
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var integer
     */
    private $level;

    /**
     * @var \PIA\appBundle\Entity\JobRules
     */
    private $jobRule;


    /**
     * Get id
     *
     * @return integer 
     */
    public function getId()
    {
        return $this->id;
    }

    /**
     * Set level
     *
     * @param integer $level
     * @return JobRuleLinks
     */
    public function setLevel($level)
    {
        $this->level = $level;

        return $this;
    }

    /**
     * Get level
     *
     * @return integer 
     */
    public function getLevel()
    {
        return $this->level;
    }

    /**
     * Set jobRule
     *
     * @param \PIA\appBundle\Entity\JobRules $jobRule
     * @return JobRuleLinks
     */
    public function setJobRule(\PIA\appBundle\Entity\JobRules $jobRule = null)
    {
        $this->jobRule = $jobRule;

        return $this;
    }

    /**
     * Get jobRule
     *
     * @return \PIA\appBundle\Entity\JobRules 
     */
    public function getJobRule()
    {
        return $this->jobRule;
    }
}
