<?php

namespace PIA\appBundle\Entity;

use Doctrine\ORM\Mapping as ORM;

/**
 * JobMessages
 */
class JobMessages
{
    /**
     * @var integer
     */
    private $id;

    /**
     * @var \PIA\appBundle\Entity\Links
     */
    private $link;

    /**
     * @var \PIA\appBundle\Entity\JobNodes
     */
    private $jobNode;


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
     * Set link
     *
     * @param \PIA\appBundle\Entity\Links $link
     * @return JobMessages
     */
    public function setLink(\PIA\appBundle\Entity\Links $link = null)
    {
        $this->link = $link;

        return $this;
    }

    /**
     * Get link
     *
     * @return \PIA\appBundle\Entity\Links 
     */
    public function getLink()
    {
        return $this->link;
    }

    /**
     * Set jobNode
     *
     * @param \PIA\appBundle\Entity\JobNodes $jobNode
     * @return JobMessages
     */
    public function setJobNode(\PIA\appBundle\Entity\JobNodes $jobNode = null)
    {
        $this->jobNode = $jobNode;

        return $this;
    }

    /**
     * Get jobNode
     *
     * @return \PIA\appBundle\Entity\JobNodes 
     */
    public function getJobNode()
    {
        return $this->jobNode;
    }
    /**
     * @var \DateTime
     */
    private $mtime;

    /**
     * @var string
     */
    private $message;

    /**
     * @var \PIA\appBundle\Entity\JobRules
     */
    private $jobRule;


    /**
     * Set mtime
     *
     * @param \DateTime $mtime
     * @return JobMessages
     */
    public function setMtime($mtime)
    {
        $this->mtime = $mtime;

        return $this;
    }

    /**
     * Get mtime
     *
     * @return \DateTime 
     */
    public function getMtime()
    {
        return $this->mtime;
    }

    /**
     * Set message
     *
     * @param string $message
     * @return JobMessages
     */
    public function setMessage($message)
    {
        $this->message = $message;

        return $this;
    }

    /**
     * Get message
     *
     * @return string 
     */
    public function getMessage()
    {
        return $this->message;
    }

    /**
     * Set jobRule
     *
     * @param \PIA\appBundle\Entity\JobRules $jobRule
     * @return JobMessages
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
