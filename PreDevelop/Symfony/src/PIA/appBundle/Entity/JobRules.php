<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobRules
 */
class JobRules
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var string
     */
    private $description;

    /**
     * @var integer
     */
    private $containerOffset;

    /**
     * @var boolean
     */
    private $criticalType;

    /**
     * @var \PIA\appBundle\Entity\JobGroups
     */
    private $group;


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
     * Set description
     *
     * @param string $description
     * @return JobRules
     */
    public function setDescription($description)
    {
        $this->description = $description;

        return $this;
    }

    /**
     * Get description
     *
     * @return string 
     */
    public function getDescription()
    {
        return $this->description;
    }

    /**
     * Set containerOffset
     *
     * @param integer $containerOffset
     * @return JobRules
     */
    public function setContainerOffset($containerOffset)
    {
        $this->containerOffset = $containerOffset;

        return $this;
    }

    /**
     * Get containerOffset
     *
     * @return integer 
     */
    public function getContainerOffset()
    {
        return $this->containerOffset;
    }

    /**
     * Set criticalType
     *
     * @param boolean $criticalType
     * @return JobRules
     */
    public function setCriticalType($criticalType)
    {
        $this->criticalType = $criticalType;

        return $this;
    }

    /**
     * Get criticalType
     *
     * @return boolean 
     */
    public function getCriticalType()
    {
        return $this->criticalType;
    }

    /**
     * Set group
     *
     * @param \PIA\appBundle\Entity\JobGroups $group
     * @return JobRules
     */
    public function setGroup(\PIA\appBundle\Entity\JobGroups $group = null)
    {
        $this->group = $group;

        return $this;
    }

    /**
     * Get group
     *
     * @return \PIA\appBundle\Entity\JobGroups 
     */
    public function getGroup()
    {
        return $this->group;
    }
    /**
     * @var \PIA\appBundle\Entity\JobRuleLinks
     */
    private $link;


    /**
     * Set link
     *
     * @param \PIA\appBundle\Entity\JobRuleLinks $link
     * @return JobRules
     */
    public function setLink(\PIA\appBundle\Entity\JobRuleLinks $link = null)
    {
        $this->link = $link;

        return $this;
    }

    /**
     * Get link
     *
     * @return \PIA\appBundle\Entity\JobRuleLinks 
     */
    public function getLink()
    {
        return $this->link;
    }
    /**
     * @var \PIA\appBundle\Entity\JobRuleRecords
     */
    private $record;


    /**
     * Set record
     *
     * @param \PIA\appBundle\Entity\JobRuleRecords $record
     * @return JobRules
     */
    public function setRecord(\PIA\appBundle\Entity\JobRuleRecords $record = null)
    {
        $this->record = $record;

        return $this;
    }

    /**
     * Get record
     *
     * @return \PIA\appBundle\Entity\JobRuleRecords 
     */
    public function getRecord()
    {
        return $this->record;
    }
}
