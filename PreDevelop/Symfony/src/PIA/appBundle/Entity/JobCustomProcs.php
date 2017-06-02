<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobCustomProcs
 */
class JobCustomProcs
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var integer
     */
    private $scriptLangRefid;

    /**
     * @var string
     */
    private $customProcName;

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
     * Set scriptLangRefid
     *
     * @param integer $scriptLangRefid
     * @return JobCustomProcs
     */
    public function setScriptLangRefid($scriptLangRefid)
    {
        $this->scriptLangRefid = $scriptLangRefid;

        return $this;
    }

    /**
     * Get scriptLangRefid
     *
     * @return integer 
     */
    public function getScriptLangRefid()
    {
        return $this->scriptLangRefid;
    }

    /**
     * Set customProcName
     *
     * @param string $customProcName
     * @return JobCustomProcs
     */
    public function setCustomProcName($customProcName)
    {
        $this->customProcName = $customProcName;

        return $this;
    }

    /**
     * Get customProcName
     *
     * @return string 
     */
    public function getCustomProcName()
    {
        return $this->customProcName;
    }

    /**
     * Set jobRule
     *
     * @param \PIA\appBundle\Entity\JobRules $jobRule
     * @return JobCustomProcs
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
