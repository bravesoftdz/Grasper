<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobRegexp
 */
class JobRegexp
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var string
     */
    private $regexp;

    /**
     * @var \PIA\appBundle\Entity\JobRules
     */
    private $jobRule;

    /**
     * @var \PIA\appBundle\Entity\JobRegexpTypeRef
     */
    private $typeRefid;


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
     * Set regexp
     *
     * @param string $regexp
     * @return JobRegexp
     */
    public function setRegexp($regexp)
    {
        $this->regexp = $regexp;

        return $this;
    }

    /**
     * Get regexp
     *
     * @return string 
     */
    public function getRegexp()
    {
        return $this->regexp;
    }

    /**
     * Set jobRule
     *
     * @param \PIA\appBundle\Entity\JobRules $jobRule
     * @return JobRegexp
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

    /**
     * Set typeRefid
     *
     * @param \PIA\appBundle\Entity\JobRegexpTypeRef $typeRefid
     * @return JobRegexp
     */
    public function setTypeRefid(\PIA\appBundle\Entity\JobRegexpTypeRef $typeRefid = null)
    {
        $this->typeRefid = $typeRefid;

        return $this;
    }

    /**
     * Get typeRefid
     *
     * @return \PIA\appBundle\Entity\JobRegexpTypeRef 
     */
    public function getTypeRefid()
    {
        return $this->typeRefid;
    }
}
