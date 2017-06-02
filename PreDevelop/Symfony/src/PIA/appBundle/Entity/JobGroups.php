<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobGroups
 */
class JobGroups
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var string
     */
    private $notes;

    /**
     * @var \PIA\appBundle\Entity\JobLevels
     */
    private $jobLevel;


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
     * Set notes
     *
     * @param string $notes
     * @return JobGroups
     */
    public function setNotes($notes)
    {
        $this->notes = $notes;

        return $this;
    }

    /**
     * Get notes
     *
     * @return string 
     */
    public function getNotes()
    {
        return $this->notes;
    }

    /**
     * Set jobLevel
     *
     * @param \PIA\appBundle\Entity\JobLevels $jobLevel
     * @return JobGroups
     */
    public function setJobLevel(\PIA\appBundle\Entity\JobLevels $jobLevel = null)
    {
        $this->jobLevel = $jobLevel;

        return $this;
    }

    /**
     * Get jobLevel
     *
     * @return \PIA\appBundle\Entity\JobLevels 
     */
    public function getJobLevel()
    {
        return $this->jobLevel;
    }
    /**
     * @var \PIA\appBundle\Entity\JobLevels
     */
    private $level;


    /**
     * Set level
     *
     * @param \PIA\appBundle\Entity\JobLevels $level
     * @return JobGroups
     */
    public function setLevel(\PIA\appBundle\Entity\JobLevels $level = null)
    {
        $this->level = $level;

        return $this;
    }

    /**
     * Get level
     *
     * @return \PIA\appBundle\Entity\JobLevels 
     */
    public function getLevel()
    {
        return $this->level;
    }
    /**
     * @var \Doctrine\Common\Collections\Collection
     */
    private $rules;

    /**
     * Constructor
     */
    public function __construct()
    {
        $this->rules = new \Doctrine\Common\Collections\ArrayCollection();
    }

    /**
     * Add rules
     *
     * @param \PIA\appBundle\Entity\JobRules $rules
     * @return JobGroups
     */
    public function addRule(\PIA\appBundle\Entity\JobRules $rules)
    {
        $this->rules[] = $rules;

        return $this;
    }

    /**
     * Remove rules
     *
     * @param \PIA\appBundle\Entity\JobRules $rules
     */
    public function removeRule(\PIA\appBundle\Entity\JobRules $rules)
    {
        $this->rules->removeElement($rules);
    }

    /**
     * Get rules
     *
     * @return \Doctrine\Common\Collections\Collection 
     */
    public function getRules()
    {
        return $this->rules;
    }
}
