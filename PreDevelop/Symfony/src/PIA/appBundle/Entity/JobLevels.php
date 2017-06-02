<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobLevels
 */
class JobLevels {

    /**
     * @var integer
     */
    private $id;

    /**
     * @var integer
     */
    private $level;

    /**
     * @ORM\ManyToOne(targetEntity="Jobs", inversedBy="levels")
     * @ORM\JoinColumn(name="job_id", referencedColumnName="id")
     */
    private $job;

    /**
     * Get id
     *
     * @return integer 
     */
    public function getId() {
        return $this->id;
    }

    /**
     * Set level
     *
     * @param integer $level
     * @return JobLevels
     */
    public function setLevel($level) {
        $this->level = $level;

        return $this;
    }

    /**
     * Get level
     *
     * @return integer 
     */
    public function getLevel() {
        return $this->level;
    }

    /**
     * Set job
     *
     * @param \PIA\appBundle\Entity\Jobs $job
     * @return JobLevels
     */
    public function setJob(\PIA\appBundle\Entity\Jobs $job = null) {
        $this->job = $job;

        return $this;
    }

    /**
     * Get job
     *
     * @return \PIA\appBundle\Entity\Jobs 
     */
    public function getJob() {
        return $this->job;
    }

    /**
     * @var \Doctrine\Common\Collections\Collection
     */
    private $groups;

    /**
     * Constructor
     */
    public function __construct()
    {
        $this->groups = new \Doctrine\Common\Collections\ArrayCollection();
    }

    /**
     * Add groups
     *
     * @param \PIA\appBundle\Entity\JobGroups $groups
     * @return JobLevels
     */
    public function addGroup(\PIA\appBundle\Entity\JobGroups $groups)
    {
        $this->groups[] = $groups;

        return $this;
    }

    /**
     * Remove groups
     *
     * @param \PIA\appBundle\Entity\JobGroups $groups
     */
    public function removeGroup(\PIA\appBundle\Entity\JobGroups $groups)
    {
        $this->groups->removeElement($groups);
    }

    /**
     * Get groups
     *
     * @return \Doctrine\Common\Collections\Collection 
     */
    public function getGroups()
    {
        return $this->groups;
    }
}
